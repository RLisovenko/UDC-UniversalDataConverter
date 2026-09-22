#!/bin/bash

# Author: R.Lisovenko
# Date: 22.09.2026
# Description:
# Verifies that the existing Converter_UDC database contains
# the required UDC tables and view.
#
# IMPORTANT:
# This script DOES NOT create, drop or alter any database objects.

set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SERVER="mssql_2025_dev,1433"
DATABASE="Converter_UDC"

echo "------------------------------------------------------------"
echo "UDC database verification"
echo "Server   : ${SERVER}"
echo "Database : ${DATABASE}"
echo "------------------------------------------------------------"

# ------------------------------------------------------------
# 1. Check that the database exists.
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
    echo "ERROR: Database '${DATABASE}' does not exist."
    echo "No database will be created automatically."
    exit 1
fi

echo "OK: Database '${DATABASE}' exists."

# ------------------------------------------------------------
# 2. Check required UDC objects.
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
    echo "OK: All required UDC database objects exist."
    echo
    echo "  dbo.data_measurement      [TABLE]"
    echo "  dbo.data_measure_map      [TABLE]"
    echo "  dbo.field_mapping_config          [TABLE]"
    echo "  dbo.list_measurement_parameter    [TABLE]"
    echo "  dbo.vw_data_measure_map           [VIEW]"
    echo
    echo "Verification completed successfully."
    echo "No CREATE/DROP/ALTER statements were executed."
    exit 0
fi

# ------------------------------------------------------------
# 3. Something is missing.
# Print the status of every required object.
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

echo
echo "No database objects were created or modified."
exit 1
