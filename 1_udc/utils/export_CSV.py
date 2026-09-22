# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Export standardized UDC data to CSV.
import csv
from db_con_UDC import get_connection
from utils.stamp_helper import get_export_stamp
from utils.CONSTANT_config import (EXPORT_DIR,EXPORT_FILE_PREFIX,EXPORT_DATE_FORMAT,EXPORT_FILE_NAME)

OUTPUT_FILE = EXPORT_DIR / f"{EXPORT_FILE_NAME}.csv"


"""
    Export standardized measurement data from dbo.vw_data_measure_map
    to a CSV file.

    Steps:
    1. Open SQL Server connection.
    2. Read standardized data from the export VIEW.
    3. Read column names from the query result.
    4. Write header and data rows to CSV.
    5. Close database resources.
"""

def export_to_csv():
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

    # Write SQL result to CSV
    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8-sig") as csv_file:
        writer = csv.writer(csv_file)

        # Header
        writer.writerow(columns)

        # Data
        writer.writerows(cursor.fetchall())
        writer.writerow([])
        writer.writerow([get_export_stamp()])
    cursor.close()
    connection.close()

   #OUTPUT_FILE = OUTPUT_FILE + get_export_stamp()                    
    print(f"Export completed: {OUTPUT_FILE}")

#----------------------------- python -m export.export_csv
if __name__ == "__main__":
    try:
        export_to_csv()
    except Exception as error:
        print(f"Export failed: {error}")
        raise