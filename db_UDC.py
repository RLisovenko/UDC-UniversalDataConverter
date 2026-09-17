import pyodbc


SERVER = r"localhost\sql_conv_dev"
DATABASE = "Converter_UDC"


def get_connection():
    connection_string = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(connection_string)