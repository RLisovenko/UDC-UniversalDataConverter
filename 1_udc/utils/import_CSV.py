# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Read standardized UDC CSV data and pass it to the database import repository.

import csv
from datetime import datetime
from decimal import Decimal
#from pathlib import Path

from utils.CONSTANT_config import (
    IMPORT_DIR,
    UDC_EXPORT_STAMP_PREFIX,
    UDC_IMPORT_COLUMNS
)

from utils.db.import_repository import insert_measure_map


def import_from_csv(file_name: str):
    """
    Import CSV data using the fixed standardized UDC structure.

    Dynamic column detection and configurable field mapping
    will be added in a later stage.
    """

    file_path = IMPORT_DIR / file_name    #file_path = Path(file_path)

    if not file_path.exists():
        raise FileNotFoundError(
            f"CSV file not found: {file_path}"
        )

    rows = []

    with open(
        file_path,
        "r",
        newline="",
        encoding="utf-8-sig"
    ) as csv_file:

        reader = csv.DictReader(csv_file)

        # Check standardized UDC columns
        if tuple(reader.fieldnames or []) != UDC_IMPORT_COLUMNS:
            raise ValueError(
                "CSV structure does not match the standard UDC format."
            )

        for row in reader:

            # Skip empty rows
            if not any(row.values()):
                continue

            # Skip UDC export metadata stamp
            first_value = row.get("SubjID")

            if (
                first_value
                and first_value.startswith(UDC_EXPORT_STAMP_PREFIX)
            ):
                continue

            rows.append(
                {
                    "SubjID": int(row["SubjID"]),
                    "SubjName": row["SubjName"] or None,

                    "EventDate": (
                        datetime.fromisoformat(row["EventDate"])
                        if row["EventDate"]
                        else None
                    ),

                    "ExpDate": (
                        datetime.fromisoformat(row["ExpDate"])
                        if row["ExpDate"]
                        else None
                    ),

                    "ParameterID": int(row["ParameterID"]),

                    "ParameterName": (
                        row["ParameterName"] or None
                    ),

                    "DataValue": (
                        Decimal(row["DataValue"])
                        if row["DataValue"]
                        else None
                    ),

                    "Unit": row["Unit"] or None,
                    "Comment": row["Comment"] or None
                }
            )

    imported_rows = insert_measure_map(rows)

    print(
        f"Import completed: {imported_rows} rows "
        f"from {file_path.name}"
    )

    return imported_rows