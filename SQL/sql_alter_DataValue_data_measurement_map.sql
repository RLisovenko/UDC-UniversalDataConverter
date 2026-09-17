EXEC sp_rename
    'dbo.data_measure_map.Value',
    'DataValue',
    'COLUMN';
GO

SELECT TOP (1)
    DataValue
FROM dbo.data_measure_map;