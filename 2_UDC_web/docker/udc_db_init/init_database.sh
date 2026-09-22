#!/bin/bash

# Author: R.Lisovenko
# Date: 22.09.2026
# Description:
# Runs the idempotent Converter_UDC initialization script
# and then verifies all required UDC database objects.
#
# Repeat-run behavior:
#   * Existing database/tables are not recreated.
#   * Missing objects may be created by init_database.sql.
#   * Final verification must succeed for exit code 0.

set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SERVER="mssql_2025_dev,1433"
DATABASE="Converter_UDC"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_FILE="${SCRIPT_DIR}/init_database.sql"

: "${MSSQL_SA_PASSWORD:?MSSQL_SA_PASSWORD is not set}"

echo "------------------------------------------------------------"
echo "UDC database initialization / verification"
echo "Server   : ${SERVER}"
echo "Database : ${DATABASE}"
echo "SQL file : ${SQL_FILE}"
echo "------------------------------------------------------------"

if [ ! -x "${SQLCMD}" ]; then
    echo "ERROR: sqlcmd not found or not executable: ${SQLCMD}"
    exit 1
fi

if [ ! -f "${SQL_FILE}" ]; then
    echo "ERROR: SQL initialization file not found: ${SQL_FILE}"
    exit 1
fi

# ------------------------------------------------------------
# 1. Execute the idempotent SQL initialization.
#
# init_database.sql itself checks whether the database,
# schemas and tables already exist before creating them.
# -b makes sqlcmd return a non-zero exit code on SQL errors.
# ------------------------------------------------------------
echo
echo "Running idempotent database initialization..."

"${SQLCMD}" \
    -S "${SERVER}" \
    -U sa \
    -P "${MSSQL_SA_PASSWORD}" \
    -C \
    -b \
    -i "${SQL_FILE}"

echo
echo "SQL initialization completed."

# ------------------------------------------------------------
# 2. Verify that the database exists.
# ------------------------------------------------------------
DB_EXISTS="$(
    "${SQLCMD}" \
        -S "${SERVER}" \
        -U sa \
        -P "${MSSQL_SA_PASSWORD}" \
        -C \
        -b \
        -d master \
        -h -1 \
        -W \
        -Q "
            SET NOCOUNT ON;
            SELECT
                CASE
                    WHEN DB_ID(N'${DATABASE}') IS NOT NULL THEN 1
                    ELSE 0
                END;
        " | tr -d '\r\n '
)"

if [ "${DB_EXISTS}" != "1" ]; then
    echo "ERROR: Database '${DATABASE}' does not exist after initialization."
    exit 1
fi

echo "OK: Database '${DATABASE}' exists."

# ------------------------------------------------------------
# 3. Verify all required UDC objects.
#
# U = user table
# V = view
# ------------------------------------------------------------
REQUIRED_OBJECTS_OK="$(
    "${SQLCMD}" \
        -S "${SERVER}" \
        -U sa \
        -P "${MSSQL_SA_PASSWORD}" \
        -C \
        -b \
        -d "${DATABASE}" \
        -h -1 \
        -W \
        -Q "
            SET NOCOUNT ON;

            SELECT
                CASE
                    WHEN
                        OBJECT_ID(N'dbo.data_measurement', N'U') IS NOT NULL
                        AND OBJECT_ID(N'dbo.data_measure_map', N'U') IS NOT NULL
                        AND OBJECT_ID(N'dbo.field_mapping_config', N'U') IS NOT NULL
                        AND OBJECT_ID(N'dbo.list_measurement_parameter', N'U') IS NOT NULL
                        AND OBJECT_ID(N'dbo.vw_data_measure_map', N'V') IS NOT NULL
                    THEN 1
                    ELSE 0
                END;
        " | tr -d '\r\n '
)"

if [ "${REQUIRED_OBJECTS_OK}" = "1" ]; then
    echo
    echo "OK: All required UDC database objects exist."
    echo
    echo "  dbo.data_measurement             [TABLE]"
    echo "  dbo.data_measure_map             [TABLE]"
    echo "  dbo.field_mapping_config         [TABLE]"
    echo "  dbo.list_measurement_parameter   [TABLE]"
    echo "  dbo.vw_data_measure_map          [VIEW]"
    echo
    echo "Verification completed successfully."
    exit 0
fi

# ------------------------------------------------------------
# 4. Verification failed.
# Print exact object status.
# ------------------------------------------------------------
echo
echo "ERROR: One or more required UDC objects are missing."
echo "Object status:"
echo

"${SQLCMD}" \
    -S "${SERVER}" \
    -U sa \
    -P "${MSSQL_SA_PASSWORD}" \
    -C \
    -b \
    -d "${DATABASE}" \
    -W \
    -s "|" \
    -Q "
        SET NOCOUNT ON;

        SELECT
            ObjectName,
            ObjectType,
            ObjectStatus
        FROM
        (
            SELECT
                1 AS SortOrder,
                'dbo.data_measurement' AS ObjectName,
                'TABLE' AS ObjectType,
                CASE
                    WHEN OBJECT_ID(N'dbo.data_measurement', N'U') IS NOT NULL
                    THEN 'OK'
                    ELSE 'MISSING'
                END AS ObjectStatus

            UNION ALL

            SELECT
                2,
                'dbo.data_measure_map',
                'TABLE',
                CASE
                    WHEN OBJECT_ID(N'dbo.data_measure_map', N'U') IS NOT NULL
                    THEN 'OK'
                    ELSE 'MISSING'
                END

            UNION ALL

            SELECT
                3,
                'dbo.field_mapping_config',
                'TABLE',
                CASE
                    WHEN OBJECT_ID(N'dbo.field_mapping_config', N'U') IS NOT NULL
                    THEN 'OK'
                    ELSE 'MISSING'
                END

            UNION ALL

            SELECT
                4,
                'dbo.list_measurement_parameter',
                'TABLE',
                CASE
                    WHEN OBJECT_ID(N'dbo.list_measurement_parameter', N'U') IS NOT NULL
                    THEN 'OK'
                    ELSE 'MISSING'
                END

            UNION ALL

            SELECT
                5,
                'dbo.vw_data_measure_map',
                'VIEW',
                CASE
                    WHEN OBJECT_ID(N'dbo.vw_data_measure_map', N'V') IS NOT NULL
                    THEN 'OK'
                    ELSE 'MISSING'
                END
        ) AS ObjectCheck
        ORDER BY SortOrder;
    "

exit 1
