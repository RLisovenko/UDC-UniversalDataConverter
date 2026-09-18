-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Align key dbo.data_measurement column data types with the canonical mapping structure.

USE Converter_UDC;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN PatientID INT NOT NULL;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN MeasurDate DATETIME2(3) NOT NULL;
GO

ALTER TABLE dbo.data_measurement
ALTER COLUMN ParameterID INT NOT NULL;
GO