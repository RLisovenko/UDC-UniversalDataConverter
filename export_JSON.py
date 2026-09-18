# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Export standardized UDC data to JSON.

import json

from db_con_UDC import get_connection
from utils.stamp_helper import get_export_stamp
from utils.CONSTANT_config import EXPORT_DIR, EXPORT_FILE_NAME


OUTPUT_FILE = EXPORT_DIR / f"{EXPORT_FILE_NAME}.json"

"""
    Export standardized measurement data from dbo.vw_data_measure_map
    to a JSON file.

    Steps:
    1. Open SQL Server connection.
    2. Read standardized data from the export VIEW.
    3. Read column names from the query result.
    4. Convert SQL rows to dictionaries.
    5. Write data to JSON.
    6. Close database resources.
"""


def export_to_json():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            SubjID,
            SubjName,
            EventDate,
            ExpDate,
            ParameterID,
            ParameterName,
            DataValue,
            Unit,
            Comment
        FROM dbo.vw_data_measure_map
        ORDER BY SubjID, EventDate, ParameterID;
    """)

    # Read column names from SQL query result
    columns = [column[0] for column in cursor.description]

    # Convert SQL rows to dictionaries:
    # {"SubjID": 1, "SubjName": "...", ...}
    rows = [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

    # Write data to JSON
    with open(
        OUTPUT_FILE,
        "w",
        encoding="utf-8"
    ) as json_file:

        json.dump(
            {
                "data": rows,
                "-----": get_export_stamp()
            },
            json_file,
            ensure_ascii=False,
            indent=4,
            default=str
        )

    cursor.close()
    connection.close()

    print(f"Export completed: {OUTPUT_FILE}")


# ----------------------------- python export_JSON_UDC.py
if __name__ == "__main__":
    try:
        export_to_json()
    except Exception as error:
        print(f"Export failed: {error}")
        raise