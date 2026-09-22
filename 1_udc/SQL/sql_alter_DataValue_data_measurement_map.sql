-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Rename the canonical measurement value column from Value to DataValue.

EXEC sp_rename
    'dbo.data_measure_map.Value',
    'DataValue',
    'COLUMN';
GO

SELECT TOP (1)
    DataValue
FROM dbo.data_measure_map;