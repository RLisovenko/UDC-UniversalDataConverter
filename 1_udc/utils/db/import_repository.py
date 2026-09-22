# Author: R.Lisovenko
# Date: 18.09.2026
# Description: Insert standardized UDC import data into dbo.data_measure_map.

from db_con_UDC import get_connection
from utils.CONSTANT_config import IMPORT_TABLE


def insert_measure_map(rows):
    """
    Insert standardized import rows into the UDC mapping table.
    """

    if not rows:
        return 0

    connection = get_connection()
    cursor = connection.cursor()

    sql = f"""
        INSERT INTO {IMPORT_TABLE}
        (
            SubjID,
            SubjName,
            ImpDate,
            EventDate,
            ExpDate,
            ParameterID,
            ParameterName,
            DataValue,
            Unit,
            Comment
        )
        VALUES
        (
            ?,
            ?,
            SYSUTCDATETIME(),
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        );
    """

    values = [
        (
            row["SubjID"],
            row["SubjName"],
            row["EventDate"],
            row["ExpDate"],
            row["ParameterID"],
            row["ParameterName"],
            row["DataValue"],
            row["Unit"],
            row["Comment"]
        )
        for row in rows
    ]

    try:
        cursor.executemany(sql, values)
        connection.commit()

        return len(values)

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()