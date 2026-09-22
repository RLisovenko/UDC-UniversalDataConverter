# Author: R.Lisovenko
# Date: 17.09.2026
# Description: Create and return a connection to the UDC SQL Server database.

import pyodbc
from utils.CONSTANT_config import (SERVER,DATABASE,DRIVER)

def get_connection():
    connection_string = (
        DRIVER
        + f"SERVER={SERVER};"
        + f"DATABASE={DATABASE};"
        + "Trusted_Connection=yes;"
        + "Encrypt=yes;"
        + "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(connection_string)