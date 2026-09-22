# Author: R.Lisovenko
# Date: 22.09.2026
# Description: Flask web application for the Universal Data Converter.

import os
import csv
from collections import deque
from datetime import datetime
from pathlib import Path
from threading import Lock

from flask import (
    Flask,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    send_file,
    url_for,
)
from werkzeug.utils import secure_filename

from db_con_UDC import get_connection
from export_data import export_data
from utils.CONSTANT_config import (
    AUTHOR,
    SERVER,
    DATABASE,
    EXPORT_DIR,
    IMPORT_DIR,
    UDC_IMPORT_COLUMNS,
)

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY") or os.urandom(24)

ALLOWED_IMPORT_EXTENSIONS = {"csv"}
UI_AUTHOR = "LiR"

# ------------------------------------------------------------------
# File activity ticker
# ------------------------------------------------------------------
# In-memory history is enough for the current single-process Flask
# container. If the app later moves to multiple workers, this can be
# replaced by a DB table / Redis without changing the frontend API.
FILE_ACTIVITY = deque(maxlen=100)
FILE_ACTIVITY_LOCK = Lock()


def add_file_activity(operation, filename, status, detail=""):
    """
    Create or update one file-operation record.

    Lifecycle:
        RUNNING -> OK
        RUNNING -> ERROR

    RUNNING creates a new row.
    OK / ERROR update the latest RUNNING row for the same operation,
    so Recent operations contains one row per operation instead of
    separate RUNNING and final-status rows.
    """
    now = datetime.now().strftime("%H:%M:%S")

    with FILE_ACTIVITY_LOCK:

        if status in {"OK", "ERROR"}:
            # Update the latest unfinished operation of the same type.
            for event in reversed(FILE_ACTIVITY):
                if (
                    event["operation"] == operation
                    and event["status"] == "RUNNING"
                ):
                    event["time"] = now
                    event["filename"] = filename
                    event["status"] = status
                    event["detail"] = detail
                    return

        # RUNNING, or a final status without a matching RUNNING row.
        FILE_ACTIVITY.append(
            {
                "time": now,
                "operation": operation,
                "filename": filename,
                "status": status,
                "detail": detail,
            }
        )



def get_recent_activity(operation=None, limit=10):
    """
    Return recent file operations newest first.
    """
    with FILE_ACTIVITY_LOCK:
        events = list(FILE_ACTIVITY)

    if operation:
        operation = operation.upper()
        events = [
            event
            for event in events
            if event["operation"] == operation
        ]

    return list(reversed(events[-limit:]))


def list_import_test_files():
    """
    Return CSV files already available in the shared import folder.
    """
    import_dir = Path(IMPORT_DIR)
    import_dir.mkdir(parents=True, exist_ok=True)

    return sorted(
        path.name
        for path in import_dir.glob("*.csv")
        if path.is_file()
    )


def list_export_example_files():
    """
    Return existing supported export examples from the shared export folder.
    """
    export_dir = Path(EXPORT_DIR)
    export_dir.mkdir(parents=True, exist_ok=True)

    supported = {".csv", ".json", ".xml"}

    files = [
        path
        for path in export_dir.iterdir()
        if path.is_file()
        and path.suffix.lower() in supported
    ]

    files.sort(
        key=lambda path: path.stat().st_mtime,
        reverse=True,
    )

    return [
        {
            "name": path.name,
            "format": path.suffix.lstrip(".").upper(),
            "size": path.stat().st_size,
        }
        for path in files[:12]
    ]


def validate_csv_import_file(file_path):
    """
    Validate the current CSV test-import structure.

    This validates the CSV stage only.
    The database import dispatcher is not connected here yet.
    """
    file_path = Path(file_path)

    with file_path.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as csv_file:
        reader = csv.DictReader(csv_file)

        actual_columns = tuple(reader.fieldnames or ())
        expected_columns = tuple(UDC_IMPORT_COLUMNS)

        if actual_columns != expected_columns:
            raise ValueError(
                "CSV columns do not match UDC import structure. "
                f"Expected: {', '.join(expected_columns)}"
            )

        row_count = sum(1 for row in reader if any(row.values()))

    if row_count == 0:
        raise ValueError("CSV file contains no data rows.")

    return row_count



def get_db_objects():
    """
    Return user tables and views available in the UDC database.

    Result format:
        dbo.table_name
        dbo.view_name
    """
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            s.name AS SchemaName,
            o.name AS ObjectName
        FROM sys.objects AS o
        INNER JOIN sys.schemas AS s
            ON s.schema_id = o.schema_id
        WHERE
            o.type IN ('U', 'V')
            AND o.is_ms_shipped = 0
        ORDER BY
            s.name,
            o.name;
    """)

    objects = [
        f"{row[0]}.{row[1]}"
        for row in cursor.fetchall()
    ]

    cursor.close()
    connection.close()

    return objects


def read_db_object(object_name, limit=100):
    """
    Read rows from a validated database table/view.
    """
    available_objects = get_db_objects()

    if object_name not in available_objects:
        raise ValueError(f"Unknown database object: {object_name}")

    limit = max(1, min(int(limit), 1000))

    schema_name, object_only_name = object_name.split(".", 1)

    # Object name has already been validated against sys.objects.
    schema_sql = schema_name.replace("]", "]]")
    object_sql = object_only_name.replace("]", "]]")

    sql = (
        f"SELECT TOP {limit} * "
        f"FROM [{schema_sql}].[{object_sql}]"
    )

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(sql)

    columns = [
        column[0]
        for column in cursor.description
    ]

    rows = cursor.fetchall()

    cursor.close()
    connection.close()

    return columns, rows



@app.context_processor
def inject_system_info():
    """
    Provide system information to every Jinja template.

    Home keeps the full System section.
    Other pages use the same values in the compact bottom ticker.
    """
    connected = False
    database_name = DATABASE

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT DB_NAME()")
        database_name = cursor.fetchone()[0]
        connected = True

        cursor.close()
        connection.close()

    except Exception:
        connected = False

    return {
        "system_application": "Converter_2 / UDC",
        "system_author": UI_AUTHOR,
        "system_server": SERVER,
        "system_database": database_name,
        "system_connected": connected,
    }


@app.route("/")
def index():
    """
    Main UDC web page.
    """
    db_connected = False
    database_name = DATABASE

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT DB_NAME()")
        database_name = cursor.fetchone()[0]
        db_connected = True

        cursor.close()
        connection.close()

    except Exception:
        db_connected = False

    return render_template(
        "index.html",
        active_page="home",
        author=UI_AUTHOR,
        server_name=SERVER,
        database_name=database_name,
        db_connected=db_connected,
    )



@app.route("/about")
def about():
    """
    Project notes / prototype description.
    """
    return render_template(
        "about.html",
        active_page="about",
    )


@app.route("/db-status")
def db_status():
    """
    Compatibility endpoint for the previous web version.
    """
    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT DB_NAME()")
        database_name = cursor.fetchone()[0]

        cursor.close()
        connection.close()

        return {
            "server": SERVER,
            "database": database_name,
            "status": "Connected",
        }

    except Exception as error:
        return {
            "server": SERVER,
            "database": DATABASE,
            "status": "Connection error",
            "error": str(error),
        }, 500


@app.route("/api/activity")
def api_activity():
    """
    Return recent import/export file activity.
    """
    operation = request.args.get("operation", "").strip() or None

    return jsonify(
        get_recent_activity(
            operation=operation,
            limit=20,
        )
    )


@app.route("/db-view")
def db_view():
    """
    Browse UDC tables and views.
    """
    tables = []
    selected_table = request.args.get("table", "").strip()
    limit = request.args.get("limit", "100").strip()

    columns = []
    rows = []

    try:
        tables = get_db_objects()

        if selected_table:
            columns, rows = read_db_object(
                selected_table,
                limit=limit,
            )

    except Exception as error:
        flash(f"DB View error: {error}")

    return render_template(
        "db_view.html",
        active_page="db_view",
        tables=tables,
        selected_table=selected_table,
        limit=limit,
        columns=columns,
        rows=rows,
        row_count=len(rows),
    )


@app.route("/export", methods=["GET", "POST"])
def export_page():
    """
    Generate UDC exports in the implemented test formats:
    CSV, JSON and XML.
    """
    if request.method == "POST":
        export_type = request.form.get(
            "format",
            "csv",
        ).strip().lower()

        activity_name = f"UDC export (*.{export_type})"

        if export_type not in {"csv", "json", "xml"}:
            add_file_activity(
                "EXPORT",
                activity_name,
                "ERROR",
                "Unsupported export format",
            )
            flash("Unsupported export format.")
            return redirect(url_for("export_page"))

        try:
            add_file_activity(
                "EXPORT",
                activity_name,
                "RUNNING",
                "Generating file",
            )

            Path(EXPORT_DIR).mkdir(
                parents=True,
                exist_ok=True,
            )

            before = {
                path.resolve(): path.stat().st_mtime_ns
                for path in Path(EXPORT_DIR).glob(f"*.{export_type}")
            }

            export_data(export_type)

            generated_files = list(
                Path(EXPORT_DIR).glob(
                    f"*.{export_type}"
                )
            )

            if not generated_files:
                raise FileNotFoundError(
                    "Exporter finished, but no output file was found."
                )

            changed_files = [
                path
                for path in generated_files
                if (
                    path.resolve() not in before
                    or path.stat().st_mtime_ns
                    != before[path.resolve()]
                )
            ]

            candidates = changed_files or generated_files

            output_file = max(
                candidates,
                key=lambda path: path.stat().st_mtime_ns,
            )

            add_file_activity(
                "EXPORT",
                output_file.name,
                "OK",
                f"{output_file.stat().st_size} bytes · app/export",
            )

            return send_file(
                output_file,
                as_attachment=True,
                download_name=output_file.name,
            )

        except Exception as error:
            add_file_activity(
                "EXPORT",
                activity_name,
                "ERROR",
                str(error),
            )
            flash(f"Export failed: {error}")
            return redirect(url_for("export_page"))

    return render_template(
        "export.html",
        active_page="export",
        export_examples=list_export_example_files(),
        recent_operations=get_recent_activity(
            operation="EXPORT",
            limit=10,
        ),
    )


@app.route("/import", methods=["GET", "POST"])
def import_page():
    """
    Current web test implementation:
    CSV upload + UDC CSV structure validation.

    The database import dispatcher is intentionally not connected yet.
    """
    import_result = None
    import_summary = None

    completed_file = request.args.get("completed", "").strip()
    completed_rows = request.args.get("rows", type=int)

    if completed_file and completed_rows is not None:
        import_summary = {
            "file": completed_file,
            "rows": completed_rows,
            "target": "dbo.data_measurement",
            "stage": "CSV validation completed",
        }

    if request.method == "POST":

        uploaded_file = request.files.get("file")

        if not uploaded_file or not uploaded_file.filename:
            flash("Select a CSV file.")
            return redirect(url_for("import_page"))

        filename = secure_filename(
            uploaded_file.filename
        )

        extension = (
            filename.rsplit(".", 1)[1].lower()
            if "." in filename
            else ""
        )

        if extension not in ALLOWED_IMPORT_EXTENSIONS:
            add_file_activity(
                "IMPORT",
                filename or "unknown file",
                "ERROR",
                "Only CSV is implemented in this test version",
            )
            flash(
                "Unsupported import format. "
                "The current test implementation supports CSV only."
            )
            return redirect(url_for("import_page"))

        try:
            add_file_activity(
                "IMPORT",
                filename,
                "RUNNING",
                "Uploading and validating CSV",
            )

            import_dir = Path(IMPORT_DIR)
            import_dir.mkdir(
                parents=True,
                exist_ok=True,
            )

            target_file = import_dir / filename
            uploaded_file.save(target_file)

            row_count = validate_csv_import_file(
                target_file
            )

            add_file_activity(
                "IMPORT",
                target_file.name,
                "OK",
                f"{row_count} rows validated · app/import",
            )

            import_result = (
                f"CSV uploaded and validated: {target_file.name} "
                f"({row_count} data rows). "
                "Database import dispatcher is not connected yet."
            )

            import_summary = {
                "file": target_file.name,
                "rows": row_count,
                "target": "dbo.data_measurement",
                "stage": "CSV validation completed",
            }

        except Exception as error:
            add_file_activity(
                "IMPORT",
                filename,
                "ERROR",
                str(error),
            )
            flash(f"CSV import validation failed: {error}")

    return render_template(
        "import.html",
        active_page="import",
        import_result=import_result,
        import_summary=import_summary,
        test_files=list_import_test_files(),
        recent_operations=get_recent_activity(
            operation="IMPORT",
            limit=10,
        ),
    )


@app.post("/import/test-file")
def import_test_file():
    """
    Load one of the ready-to-use CSV files already mounted in /app/import.
    No browser file picker is required.
    """
    filename = secure_filename(
        request.form.get("filename", "")
    )

    if not filename or not filename.lower().endswith(".csv"):
        flash("Invalid CSV test file.")
        return redirect(url_for("import_page"))

    import_dir = Path(IMPORT_DIR).resolve()
    file_path = (import_dir / filename).resolve()

    try:
        # Prevent path traversal and require a real file in IMPORT_DIR.
        if file_path.parent != import_dir:
            raise ValueError("Invalid test file path.")

        if not file_path.is_file():
            raise FileNotFoundError(
                f"Test file not found: {filename}"
            )

        add_file_activity(
            "IMPORT",
            filename,
            "RUNNING",
            "Loading ready test CSV",
        )

        row_count = validate_csv_import_file(
            file_path
        )

        add_file_activity(
            "IMPORT",
            filename,
            "OK",
            f"{row_count} rows validated · ready test file",
        )

        return redirect(
            url_for(
                "import_page",
                completed=filename,
                rows=row_count,
            )
        )

    except Exception as error:
        add_file_activity(
            "IMPORT",
            filename or "test file",
            "ERROR",
            str(error),
        )
        flash(f"Test CSV validation failed: {error}")

    return redirect(url_for("import_page"))


if __name__ == "__main__":

    # 0.0.0.0 is required so Flask is reachable
    # from outside the Docker container.
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=False,
    )
