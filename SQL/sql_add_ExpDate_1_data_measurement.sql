-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Add ExpDate to dbo.data_measurement and document its export-time purpose.

USE Converter_UDC;
GO


/* ============================================================
   ADD EXPORT DATE TO MEASUREMENT DATA
   ============================================================ */

ALTER TABLE dbo.data_measurement
ADD ExpDate DATETIME2(3) NULL;
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'UTC date and time when the record was exported to an external system or research partner.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ExpDate';
GO