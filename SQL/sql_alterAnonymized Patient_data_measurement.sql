ALTER TABLE dbo.data_measure_map
ADD CONSTRAINT DF_data_measure_map_SubjName
DEFAULT ('Anonymized Patient') FOR SubjName;
GO