USE Converter_UDC;
GO


/* ============================================================
   TABLE: dbo.data_measure_map

   PURPOSE:
   Stores standardized measurement data fields used by the
   converter as an intermediate exchange structure.
   ============================================================ */

CREATE TABLE dbo.data_measure_map
(
    ID              INT IDENTITY(1,1) NOT NULL,

    SubjID          INT NULL,
    SubjName        VARCHAR(200) NULL,

    ImpDate         DATETIME2(3) NULL,
    EventDate       DATETIME2(3) NULL,
    ExpDate         DATETIME2(3) NULL,

    ParameterID     INT NULL,
    ParameterName   VARCHAR(200) NULL,

    Value           DECIMAL(18,6) NULL,
    Unit            VARCHAR(32) NULL,

    Comment         VARCHAR(1000) NULL,

    CONSTRAINT PK_data_measure_map
        PRIMARY KEY (ID)
);
GO


/* ============================================================
   TABLE DESCRIPTION
   ============================================================ */

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores standardized measurement data fields used by the converter as an intermediate exchange structure between external data sources and the internal database model.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map';
GO


/* ============================================================
   COLUMN DESCRIPTIONS
   ============================================================ */

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Internal unique identifier of the mapping record.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'ID';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized numeric identifier of the subject associated with the measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'SubjID';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized subject name or anonymized subject description.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'SubjName';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the data record was imported into the converter process.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'ImpDate';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time of the measurement or related event.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'EventDate';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the data record was exported from the converter process.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'ExpDate';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized numeric identifier of the measured parameter.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'ParameterID';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized human-readable name of the measured parameter.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'ParameterName';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized numeric value of the measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'Value';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Standardized unit of measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'Unit';
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional standardized comment or additional information associated with the measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measure_map',
    @level2type = N'COLUMN',
    @level2name = N'Comment';
GO