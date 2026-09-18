-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Increase UDC date/time precision to DATETIME2(7) for import/export sequencing.

USE Converter_UDC;
GO

-- dbo.data_measurement
ALTER TABLE dbo.data_measurement
ALTER COLUMN MeasurDate DATETIME2(7) NOT NULL;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN CreateDate DATETIME2(7) NOT NULL;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN UpdDate DATETIME2(7) NULL;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN ExpDate DATETIME2(7) NULL;
GO

-- dbo.data_measure_map
ALTER TABLE dbo.data_measure_map
ALTER COLUMN ImpDate DATETIME2(7) NULL;
GO

ALTER TABLE dbo.data_measure_map
ALTER COLUMN EventDate DATETIME2(7) NULL;
GO

ALTER TABLE dbo.data_measure_map
ALTER COLUMN ExpDate DATETIME2(7) NULL;
GO
