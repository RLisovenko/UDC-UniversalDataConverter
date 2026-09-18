# Author: R.Lisovenko
# Date: 17.09.2026
# Description: Display all UDC database tables and views using Pandas.

import pandas as pd

from db_con_UDC import get_connection


def show_database_objects():
    """
    Display all tables and views from the UDC database.

    Steps:
    1. Open SQL Server connection.
    2. Read the list of database tables and views.
    3. Read all rows from every object.
    4. Convert SQL results to Pandas DataFrames.
    5. Display each DataFrame in the console.
    6. Close database resources.
    """

    connection = get_connection()
    cursor = connection.cursor()

    try:
        # Read all user tables and views
        cursor.execute("""
            SELECT
                TABLE_SCHEMA,
                TABLE_NAME,
                TABLE_TYPE
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE IN ('BASE TABLE', 'VIEW')
            ORDER BY TABLE_TYPE, TABLE_NAME;
        """)

        database_objects = cursor.fetchall()

        for schema_name, object_name, object_type in database_objects:

            print("\n" + "=" * 100)
            print(f"{object_type}: {schema_name}.{object_name}")
            print("=" * 100)

            query = f"""
                SELECT *
                FROM [{schema_name}].[{object_name}];
            """

            cursor.execute(query)

            # Read column names
            columns = [
                column[0]
                for column in cursor.description
            ]

            # Read data
            rows = cursor.fetchall()

            # Convert SQL result to Pandas DataFrame
            dataframe = pd.DataFrame.from_records(
                rows,
                columns=columns
            )

            if dataframe.empty:
                print("[EMPTY]")
            else:
                print(
                    dataframe.to_string(
                        index=False
                    )
                )

            print(f"\nRows: {len(dataframe)}")

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    try:
        show_database_objects()

    except Exception as error:
        print(f"Database viewer failed: {error}")
        raise