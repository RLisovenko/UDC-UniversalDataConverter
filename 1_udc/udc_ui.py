# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Simple graphical interface for UDC export and import demonstration.

import tkinter as tk

from datetime import datetime
from pathlib import Path
from tkinter import ttk, messagebox, filedialog

import utils.export_CSV as export_csv
import utils.export_JSON as export_json
import utils.export_XML as export_xml

from utils.CONSTANT_config import (
    IMPORT_DIR,
    EXPORT_DIR,
    DATABASE,
    IMPORT_TABLE,
    EXPORT_FILE_PREFIX,
    EXPORT_DATE_FORMAT
)

from utils.import_CSV import import_from_csv


# ----------------------------------------------------------------------
# Export
# ----------------------------------------------------------------------

def toggle_export_path():
    """
    Unlock or lock manual export directory selection.
    """

    if unlock_export_path.get():

        export_output_entry.config(
            state="normal"
        )

        export_browse_button.config(
            state="normal"
        )

        status_var.set(
            "Export directory unlocked."
        )

    else:

        export_output.set(
            str(EXPORT_DIR)
        )

        export_output_entry.config(
            state="readonly"
        )

        export_browse_button.config(
            state="disabled"
        )

        status_var.set(
            "Default export directory restored."
        )


def browse_export_directory():
    """
    Select another export directory.
    Available only when output path is unlocked.
    """

    if not unlock_export_path.get():
        return

    directory = filedialog.askdirectory(
        title="Select export directory",
        initialdir=export_output.get()
    )

    if directory:

        export_output.set(
            directory
        )

        status_var.set(
            f"Selected export directory:\n"
            f"{directory}"
        )


def refresh_export_formats():
    """
    Refresh available export formats.
    """

    export_combo["values"] = (
        "CSV",
        "JSON",
        "XML",
        "ALL"
    )

    if export_format.get() not in export_combo["values"]:
        export_format.set("CSV")

    if not unlock_export_path.get():

        export_output.set(
            str(EXPORT_DIR)
        )

    status_var.set(
        "Export settings refreshed."
    )


def prepare_export_files():
    """
    Prepare output file names for the current export operation.

    A new timestamp is generated for every export operation.
    ALL formats use the same timestamp.
    """

    output_value = export_output.get().strip()

    if not output_value:

        raise ValueError(
            "Export directory cannot be empty."
        )

    output_directory = Path(
        output_value
    )

    output_directory.mkdir(
        parents=True,
        exist_ok=True
    )

    export_timestamp = datetime.now().strftime(
        EXPORT_DATE_FORMAT
    )

    export_file_name = (
        f"{EXPORT_FILE_PREFIX}_{export_timestamp}"
    )

    export_csv.OUTPUT_FILE = (
        output_directory /
        f"{export_file_name}.csv"
    )

    export_json.OUTPUT_FILE = (
        output_directory /
        f"{export_file_name}.json"
    )

    export_xml.OUTPUT_FILE = (
        output_directory /
        f"{export_file_name}.xml"
    )


def run_export():
    """
    Run selected export operation.
    """

    export_type = export_format.get().upper()

    try:

        prepare_export_files()

        status_var.set(
            f"Exporting {export_type}..."
        )

        root.update_idletasks()

        exported_files = []

        match export_type:

            case "CSV":

                export_csv.export_to_csv()

                exported_files.append(
                    export_csv.OUTPUT_FILE
                )

            case "JSON":

                export_json.export_to_json()

                exported_files.append(
                    export_json.OUTPUT_FILE
                )

            case "XML":

                export_xml.export_to_xml()

                exported_files.append(
                    export_xml.OUTPUT_FILE
                )

            case "ALL":

                export_csv.export_to_csv()
                export_json.export_to_json()
                export_xml.export_to_xml()

                exported_files.extend(
                    [
                        export_csv.OUTPUT_FILE,
                        export_json.OUTPUT_FILE,
                        export_xml.OUTPUT_FILE
                    ]
                )

            case _:

                raise ValueError(
                    f"Unsupported export format: {export_type}"
                )

        exported_file_list = "\n".join(
            f"  - {file_path.name}"
            for file_path in exported_files
        )

        status_var.set(
            f"Export completed successfully:\n"
            f"{exported_file_list}\n"
            f"Directory: {exported_files[0].parent}"
        )

    except Exception as error:

        status_var.set(
            "Export failed."
        )

        messagebox.showerror(
            "Export error",
            str(error)
        )


# ----------------------------------------------------------------------
# Import
# ----------------------------------------------------------------------

def refresh_import_files():
    """
    Refresh available files in the standard import directory.
    """

    file_type = import_type.get().upper()

    if file_type == "CSV":

        files = sorted(
            file_path.name
            for file_path in IMPORT_DIR.glob("*.csv")
        )

    else:

        files = []

    if files:

        import_file_combo["values"] = (
            ["ALL"] + files
        )

        import_file_combo.current(1)

        file_list = "\n".join(
            f"  - {file_name}"
            for file_name in files
        )

        status_var.set(
            f"{len(files)} {file_type} import file(s) found:\n"
            f"{file_list}"
        )

    else:

        import_file_combo["values"] = []

        import_file_name.set("")

        status_var.set(
            f"No {file_type} files found in:\n"
            f"{IMPORT_DIR}"
        )


def browse_import_file():
    """
    Select an import file from any directory.
    """

    file_type = import_type.get().upper()

    if file_type == "CSV":

        file_types = [
            ("CSV files", "*.csv"),
            ("All files", "*.*")
        ]

    else:

        file_types = [
            ("All files", "*.*")
        ]

    file_path = filedialog.askopenfilename(
        title="Select import file",
        initialdir=IMPORT_DIR,
        filetypes=file_types
    )

    if file_path:

        import_file_name.set(
            file_path
        )

        status_var.set(
            f"Selected import file:\n"
            f"{file_path}"
        )


def run_import():
    """
    Import selected CSV file or all CSV files
    from the standard import directory.
    """

    file_type = import_type.get().upper()
    file_name = import_file_name.get().strip()

    if not file_name:

        messagebox.showwarning(
            "Import",
            "Please select an import file."
        )

        return

    try:

        # --------------------------------------------------------------
        # Current implementation: CSV only
        # --------------------------------------------------------------

        if file_type != "CSV":

            raise ValueError(
                f"Import format is not implemented yet: {file_type}"
            )

        # --------------------------------------------------------------
        # Import ALL CSV files
        # --------------------------------------------------------------

        if file_name == "ALL":

            files = sorted(
                IMPORT_DIR.glob("*.csv")
            )

            if not files:

                raise ValueError(
                    "No CSV files available for import."
                )

            total_rows = 0
            imported_files = []

            for file_path in files:

                status_var.set(
                    f"Importing:\n"
                    f"{file_path.name}"
                )

                root.update_idletasks()

                imported_rows = import_from_csv(
                    file_path.name
                )

                total_rows += imported_rows

                imported_files.append(
                    file_path.name
                )

            imported_file_list = "\n".join(
                f"  - {file_name}"
                for file_name in imported_files
            )

            status_var.set(
                f"Import completed successfully:\n"
                f"{imported_file_list}\n"
                f"Files: {len(imported_files)} | "
                f"Rows: {total_rows}"
            )

            return

        # --------------------------------------------------------------
        # Import selected file
        # --------------------------------------------------------------

        status_var.set(
            f"Importing:\n"
            f"{file_name}"
        )

        root.update_idletasks()

        imported_rows = import_from_csv(
            file_name
        )

        selected_file = Path(
            file_name
        )

        status_var.set(
            f"Import completed successfully:\n"
            f"  - {selected_file.name}\n"
            f"Rows imported: {imported_rows}"
        )

    except Exception as error:

        status_var.set(
            "Import failed."
        )

        messagebox.showerror(
            "Import error",
            str(error)
        )


# ----------------------------------------------------------------------
# Main window
# ----------------------------------------------------------------------

root = tk.Tk()

root.title(
    "Universal Data Converter"
)

root.geometry(
    "1100x650"
)

root.resizable(
    False,
    False
)


# ----------------------------------------------------------------------
# Main frame
# ----------------------------------------------------------------------

main_frame = ttk.Frame(
    root,
    padding=20
)

main_frame.pack(
    fill="both",
    expand=True
)


# ----------------------------------------------------------------------
# Header
# ----------------------------------------------------------------------

title_label = ttk.Label(
    main_frame,
    text="Universal Data Converter",
    font=("Segoe UI", 18, "bold")
)

title_label.pack(
    pady=(0, 3)
)


author_label = ttk.Label(
    main_frame,
    text="Author: LiR",
    font=("Segoe UI", 10)
)

author_label.pack(
    pady=(0, 20)
)


# ----------------------------------------------------------------------
# Export / Import container
# ----------------------------------------------------------------------

data_frame = ttk.Frame(
    main_frame
)

data_frame.pack(
    fill="x",
    pady=(0, 15)
)

data_frame.columnconfigure(
    0,
    weight=1
)

data_frame.columnconfigure(
    1,
    weight=1
)


# ----------------------------------------------------------------------
# EXPORT - LEFT
# ----------------------------------------------------------------------

export_frame = ttk.LabelFrame(
    data_frame,
    text="EXPORT",
    padding=15
)

export_frame.grid(
    row=0,
    column=0,
    padx=(0, 8),
    sticky="nsew"
)

export_frame.columnconfigure(
    1,
    weight=1
)


# File type
ttk.Label(
    export_frame,
    text="File type:"
).grid(
    row=0,
    column=0,
    padx=5,
    pady=5,
    sticky="w"
)


export_format = tk.StringVar(
    value="ALL"
)


export_combo = ttk.Combobox(
    export_frame,
    textvariable=export_format,
    values=(
        "CSV",
        "JSON",
        "XML",
        "ALL"
    ),
    state="readonly",
    width=24
)

export_combo.grid(
    row=0,
    column=1,
    columnspan=2,
    padx=10,
    pady=5,
    sticky="ew"
)


# Output directory
ttk.Label(
    export_frame,
    text="Output:"
).grid(
    row=1,
    column=0,
    padx=5,
    pady=5,
    sticky="w"
)


export_output = tk.StringVar(
    value=str(EXPORT_DIR)
)


export_output_entry = ttk.Entry(
    export_frame,
    textvariable=export_output,
    state="readonly"
)

export_output_entry.grid(
    row=1,
    column=1,
    padx=(10, 5),
    pady=5,
    sticky="ew"
)


# Browse output directory
export_browse_button = ttk.Button(
    export_frame,
    text="Browse...",
    command=browse_export_directory,
    state="disabled"
)

export_browse_button.grid(
    row=1,
    column=2,
    padx=(5, 10),
    pady=5,
    sticky="e"
)


# Unlock output path
unlock_export_path = tk.BooleanVar(
    value=False
)


unlock_export_checkbox = ttk.Checkbutton(
    export_frame,
    text="Unlock output path",
    variable=unlock_export_path,
    command=toggle_export_path
)

unlock_export_checkbox.grid(
    row=2,
    column=1,
    columnspan=2,
    padx=10,
    pady=(5, 2),
    sticky="w"
)


# Export buttons
ttk.Button(
    export_frame,
    text="Refresh",
    command=refresh_export_formats
).grid(
    row=3,
    column=0,
    padx=5,
    pady=10,
    sticky="w"
)


ttk.Button(
    export_frame,
    text="Export",
    command=run_export
).grid(
    row=3,
    column=2,
    padx=10,
    pady=10,
    sticky="e"
)


# ----------------------------------------------------------------------
# IMPORT - RIGHT
# ----------------------------------------------------------------------

import_frame = ttk.LabelFrame(
    data_frame,
    text="IMPORT",
    padding=15
)

import_frame.grid(
    row=0,
    column=1,
    padx=(8, 0),
    sticky="nsew"
)

import_frame.columnconfigure(
    1,
    weight=1
)


# File type
ttk.Label(
    import_frame,
    text="File type:"
).grid(
    row=0,
    column=0,
    padx=5,
    pady=5,
    sticky="w"
)


import_type = tk.StringVar(
    value="CSV"
)


import_type_combo = ttk.Combobox(
    import_frame,
    textvariable=import_type,
    values=(
        "CSV",
    ),
    state="readonly",
    width=12
)

import_type_combo.grid(
    row=0,
    column=1,
    columnspan=2,
    padx=10,
    pady=5,
    sticky="ew"
)


import_type_combo.bind(
    "<<ComboboxSelected>>",
    lambda event: refresh_import_files()
)


# Import file
ttk.Label(
    import_frame,
    text="File:"
).grid(
    row=1,
    column=0,
    padx=5,
    pady=5,
    sticky="w"
)


import_file_name = tk.StringVar()


import_file_combo = ttk.Combobox(
    import_frame,
    textvariable=import_file_name,
    width=35
)

import_file_combo.grid(
    row=1,
    column=1,
    padx=(10, 5),
    pady=5,
    sticky="ew"
)


# Browse import file
ttk.Button(
    import_frame,
    text="Browse...",
    command=browse_import_file
).grid(
    row=1,
    column=2,
    padx=(5, 10),
    pady=5,
    sticky="e"
)


# Default directory information
ttk.Label(
    import_frame,
    text=f"Default directory: {IMPORT_DIR}"
).grid(
    row=2,
    column=1,
    columnspan=2,
    padx=10,
    pady=(5, 2),
    sticky="w"
)


# Import buttons
ttk.Button(
    import_frame,
    text="Refresh",
    command=refresh_import_files
).grid(
    row=3,
    column=0,
    padx=5,
    pady=10,
    sticky="w"
)


ttk.Button(
    import_frame,
    text="Import",
    command=run_import
).grid(
    row=3,
    column=2,
    padx=10,
    pady=10,
    sticky="e"
)


# ----------------------------------------------------------------------
# UDC Information
# ----------------------------------------------------------------------

info_frame = ttk.LabelFrame(
    main_frame,
    text="UDC Information",
    padding=15
)

info_frame.pack(
    fill="x",
    pady=(0, 15)
)


ttk.Label(
    info_frame,
    text=f"Database: {DATABASE}"
).pack(
    anchor="w"
)


ttk.Label(
    info_frame,
    text=f"Canonical import table: {IMPORT_TABLE}"
).pack(
    anchor="w"
)


ttk.Label(
    info_frame,
    text="Field mapping: Standard UDC structure"
).pack(
    anchor="w"
)


ttk.Label(
    info_frame,
    text="Custom field mapping: Planned"
).pack(
    anchor="w"
)


# ----------------------------------------------------------------------
# Status
# ----------------------------------------------------------------------

status_var = tk.StringVar(
    value="Ready"
)


status_frame = ttk.LabelFrame(
    main_frame,
    text="STATUS",
    padding=10
)

status_frame.pack(
    fill="both",
    expand=True
)


ttk.Label(
    status_frame,
    textvariable=status_var,
    justify="left"
).pack(
    anchor="w"
)


# ----------------------------------------------------------------------
# Initial data
# ----------------------------------------------------------------------

refresh_export_formats()
refresh_import_files()


# ----------------------------------------------------------------------
# Start GUI
# ----------------------------------------------------------------------

root.mainloop()