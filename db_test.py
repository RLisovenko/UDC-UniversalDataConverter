from db_UDC import get_connection

connection = get_connection()
cursor = connection.cursor()

cursor.execute("""
    SELECT
        SubjID,
        SubjName,
        EventDate,
        ExpDate,
        ParameterID,
        ParameterName,
        DataValue,
        Unit,
        Comment
    FROM dbo.vw_data_measure_map
    ORDER BY SubjID, EventDate, ParameterID;
""")

rows = cursor.fetchall()

for row in rows:
    print(row)

cursor.close()
connection.close()