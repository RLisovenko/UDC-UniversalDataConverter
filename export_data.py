# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Common UDC export dispatcher. Selects export format and starts the corresponding exporter.

from utils.export_CSV import export_to_csv
from utils.export_JSON import export_to_json
from utils.export_XML import export_to_xml


def export_data(export_type):
    """
    Export UDC data in the selected format.

    Supported formats:
    CSV
    JSON
    XML
    """

    export_type = export_type.upper()

    match export_type:

        case "CSV":
            export_to_csv()

        case "JSON":
            export_to_json()

        case "XML":
            export_to_xml()

        case "ALL":
            export_to_csv()
            export_to_json()
            export_to_xml()

        case _:
            raise ValueError(
                f"Unsupported export format: {export_type}"
            )


if __name__ == "__main__":
    try:
        exp_type = input("Enter export type (CSV/JSON/XML/ALL): [CSV]").strip()
        if not exp_type: exp_type = "CSV"
        export_data(exp_type)
    except Exception as error:
        print(f"Export failed: {error}")
        raise