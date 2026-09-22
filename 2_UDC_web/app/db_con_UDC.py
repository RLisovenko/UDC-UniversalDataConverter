# Author: R.Lisovenko
# Date: 17.09.2026
# Description: Create and return a connection to the UDC SQL Server database.

import pyodbc
from utils.CONSTANT_config import (SERVER,DATABASE,DRIVER)
import os


def get_connection():
    password = os.environ.get("MSSQL_SA_PASSWORD")
    
    connection_string = (
        f"{DRIVER}"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        f"UID=sa;"
        f"PWD={password};"
        f"Encrypt=yes;"
        f"TrustServerCertificate=yes;"
    )

    return pyodbc.connect(connection_string)