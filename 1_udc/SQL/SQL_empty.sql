-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Simple test query for reading data from the standardized export VIEW.

USE Converter_UDC;
GO
/*
    Description
*/
GO

select *
From vw_data_measure_map

SELECT *
FROM dbo.data_measure_map
ORDER BY ID;

select * 
from list_measurement_parameter

