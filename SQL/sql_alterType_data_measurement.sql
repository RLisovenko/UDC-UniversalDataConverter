USE DE_OL_Klinikum_ConverterDB;
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