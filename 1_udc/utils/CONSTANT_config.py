# Author: R.Lisovenko@outlook.com
# Date: 18.09.2026
# Description: Common constants and configuration values for UDC.

from pathlib import Path
from datetime import datetime

AUTHOR = "LiR"                                        #AUTHOR = "LiR: R.Lisovenko@outlook.com"
# -----------------------------Project directories
PROJECT_DIR = Path(__file__).resolve().parent.parent
EXPORT_DIR = PROJECT_DIR / "export"
IMPORT_DIR = PROJECT_DIR / "import"
IMPORT_DEFAULT_TYPE = "CSV"

# Export file settings / Common export file naming
TYPE_OBJ = "UDC"
EXPORT_FILE_PREFIX = "Export" + TYPE_OBJ    #EXPORT_FILE_PREFIX = "ExportUDC"

EXPORT_DATE_FORMAT = "%d_%m_%Y_%H_%M_%S"
#EXPORT_DATE_FORMAT = "%d_%m_%Y_%H_%M_%S_%f"       для больше йточности если ного данных истоников
EXPORT_TIMESTAMP = datetime.now().strftime(EXPORT_DATE_FORMAT)

EXPORT_FILE_NAME = (
    f"{EXPORT_FILE_PREFIX}_{EXPORT_TIMESTAMP}"
)
#OUTPUT_FILE = datetime.now().strftime("%d_%m_%Y_%H_%M_%S_ExportUDC.csv")               # 18_09_2026_11_27_45_ExportUDC.csv
#OUTPUT_FILE = OUTPUT_DIR / datetime.now().strftime("ExportUDC_%d_%m_%Y_%H_%M_%S.csv")   # ExportUDC_18_09_2026_11_32_45.csv 

# ----------------------------- Import settings

UDC_EXPORT_STAMP_PREFIX = f"{TYPE_OBJ} Export |"

UDC_IMPORT_COLUMNS = (
    "SubjID",
    "SubjName",
    "EventDate",
    "ExpDate",
    "ParameterID",
    "ParameterName",
    "DataValue",
    "Unit",
    "Comment",
)

#----------------------------- Database objects
DRIVER="DRIVER={ODBC Driver 18 for SQL Server};"
SERVER = r"localhost\sql_conv_dev"
DATABASE = "Converter_UDC"

EXPORT_VIEW = "dbo.vw_data_measure_map"
MEASUREMENT_TABLE = "dbo.data_measurement"
IMPORT_TABLE = "dbo.data_measure_map"
MAPPING_CONFIG_TABLE = "dbo.field_mapping_config"
