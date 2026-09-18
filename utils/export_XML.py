# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Export standardized UDC data to XML.

import xml.etree.ElementTree as ET

from db_con_UDC import get_connection
from utils.stamp_helper import get_export_stamp
from utils.CONSTANT_config import EXPORT_DIR, EXPORT_FILE_NAME


OUTPUT_FILE = EXPORT_DIR / f"{EXPORT_FILE_NAME}.xml"


"""
    Export standardized measurement data from dbo.vw_data_measure_map
    to an XML file.

    Steps:
    1. Open SQL Server connection.
    2. Read standardized data from the export VIEW.
    3. Read column names from the query result.
    4. Convert SQL rows to XML elements.
    5. Add export stamp.
    6. Write XML file.
    7. Close database resources.
"""


def export_to_xml():
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

    # Read SQL data
    rows = cursor.fetchall()

    # Root XML element
    root = ET.Element("UDCExport")

    # Data container
    data_element = ET.SubElement(root, "Data")

    # Convert every SQL row to XML
    for row in rows:
        record_element = ET.SubElement(data_element, "Record")

        for column, value in zip(columns, row):
            field_element = ET.SubElement(record_element, column)

            if value is not None:
                field_element.text = str(value)

    # Export stamp
    stamp_element = ET.SubElement(root, "-----")
    stamp_element.text = get_export_stamp()

    # Create XML tree
    tree = ET.ElementTree(root)

    # Format XML with indentation
    ET.indent(tree, space="    ")

    # Write XML file
    tree.write(
        OUTPUT_FILE,
        encoding="utf-8",
        xml_declaration=True
    )

    cursor.close()
    connection.close()

    print(f"Export completed: {OUTPUT_FILE}")


# ----------------------------- python export_XML.py
if __name__ == "__main__":
    try:
        export_to_xml()
    except Exception as error:
        print(f"Export failed: {error}")
        raise