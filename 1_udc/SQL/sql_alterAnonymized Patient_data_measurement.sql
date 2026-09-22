-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Add the default anonymized subject name for dbo.data_measure_map.SubjName.

ALTER TABLE dbo.data_measure_map
ADD CONSTRAINT DF_data_measure_map_SubjName
DEFAULT ('Anonymized Patient') FOR SubjName;
GO