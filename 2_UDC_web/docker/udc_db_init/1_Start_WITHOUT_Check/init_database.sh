#!/bin/bash

# Author: R.Lisovenko
# Date: 21.09.2026
# Description: Initializes the Converter_UDC database in the SQL Server container.

# Stop this script immediately if any command returns an error.
set -e

# Execute the database initialization SQL script on the SQL Server container.
# -S : SQL Server host and port inside the Docker Compose network.
# -U : SQL Server login.
# -P : SQL Server password from the container environment.
# -C : Trust the SQL Server certificate.
# -b : Return a non-zero exit code when a SQL error occurs.
# -i : SQL script file to execute.
/opt/mssql-tools18/bin/sqlcmd \
    -S mssql_2025_dev,1433 \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -b \
    -i "${SCR_DB_INIT}/init_database.sql"