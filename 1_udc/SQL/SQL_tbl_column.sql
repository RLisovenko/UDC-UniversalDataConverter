-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Inspect the current database and column metadata of dbo.data_measure_map.

USE Converter_UDC;
GO

SELECT
    DB_NAME() AS CurrentDatabase,
    OBJECT_ID(N'dbo.data_measure_map', N'U') AS TableObjectID;
GO

SELECT
    c.column_id,
    c.name AS ColumnName
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.data_measure_map')
ORDER BY c.column_id;