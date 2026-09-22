# Author: R.Lisovenko
# Date: 21.09.2026
# Description: Initialization image for creating the Converter_UDC database.

# Use the official Microsoft SQL Server 2025 image as the base image.
#FROM mcr.microsoft.com/mssql/server:2025-latest
FROM mssql_2025_dev:latest

# Internal container directories.
ENV DATA=/data
ENV SCR_DB_INIT=/scr_db_init

# Create directories explicitly so the container structure
# is easy to inspect and understand.
USER root
RUN mkdir -p ${DATA}
RUN mkdir -p ${SCR_DB_INIT}

# Copy database initialization scripts into the script directory.
COPY init_database.sh ${SCR_DB_INIT}/init_database.sh
COPY init_database.sql ${SCR_DB_INIT}/init_database.sql

# Make the initialization shell script executable.
RUN chmod +x ${SCR_DB_INIT}/init_database.sh

# Use the database initialization directory as the working directory.
WORKDIR ${SCR_DB_INIT}

# Return to the standard SQL Server user.
USER mssql

# Execute the database initialization process when the container starts.
ENTRYPOINT ["./init_database.sh"]