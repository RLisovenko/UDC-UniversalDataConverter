USE DE_OL_Klinikum_ConverterDB;
GO


/* ============================================================
   TABLE: dbo.data_measurement

   PURPOSE:
   Stores measurement-related data received from external
   systems and research partners.

   Patient-related source identifiers are converted through
   the mapping layer before data is stored in this table.

   The current structure is intentionally denormalized and
   may later be separated into dedicated patient, parameter,
   source system, import and export tables.
   ============================================================ */

CREATE TABLE dbo.data_measurement
(
    ID       BIGINT IDENTITY(1,1) NOT NULL,

    PatientID           VARCHAR(64) NOT NULL,

    PatientName         VARCHAR(200) NOT NULL
        CONSTRAINT DF_data_measurement_PatientName
        DEFAULT ('Anonymized Patient'),

    MeasurDate          DATETIME2(0) NOT NULL,

    ParameterID         VARCHAR(50) NOT NULL,
    ParameterName       VARCHAR(200) NULL,

    MeasurVal           DECIMAL(18,6) NULL,
    UnitCode            VARCHAR(32) NULL,

    SourceSystemID      INT NOT NULL,
    SourceSystemName    VARCHAR(200) NULL,

    ImportBatchID       UNIQUEIDENTIFIER NULL,
    ExportBatchID       UNIQUEIDENTIFIER NULL,

    CreateDate          DATETIME2(3) NOT NULL
        CONSTRAINT DF_data_measurement_CreateDate
        DEFAULT SYSUTCDATETIME(),

    UpdDate             DATETIME2(3) NULL,

    Comment             VARCHAR(1000) NULL,

    CONSTRAINT PK_data_measurement
        PRIMARY KEY (ID)
);
GO


/* ============================================================
   TABLE DESCRIPTION
   ============================================================ */

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores measurement-related data received from external systems and research partners. Source-specific structures are converted through the mapping layer before records are stored in this table.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement';
GO


/* ============================================================
   COLUMN DESCRIPTIONS
   ============================================================ */

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Internal unique identifier of the measurement record.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifier of the patient associated with the measurement. The value may originate from an anonymized or pseudonymized external subject identifier.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'PatientID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Patient display name. If no value is supplied by the mapping process, the default value Anonymized Patient is used.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'PatientName';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time of the measurement or related source event.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'MeasurDate';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifier or code of the measured parameter.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ParameterID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-readable name or description of the measured parameter.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ParameterName';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Numeric value of the measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'MeasurVal';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unit of measurement.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'UnitCode';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Internal identifier of the system or organization that supplied the data.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'SourceSystemID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-readable name of the system or organization that supplied the data.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'SourceSystemName';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier of the import batch through which the record was received.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ImportBatchID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier of the export batch through which the record was sent to an external system or partner.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'ExportBatchID';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'UTC date and time when the record was created in the converter database.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'CreateDate';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'UTC date and time when the record was last updated. NULL indicates that the record has not been updated after creation.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'UpdDate';
GO


EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional comment or additional information associated with the measurement record.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'data_measurement',
    @level2type = N'COLUMN',
    @level2name = N'Comment';
GO