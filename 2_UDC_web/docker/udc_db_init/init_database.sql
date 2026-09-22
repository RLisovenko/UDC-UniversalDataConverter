-- Author: R.Lisovenko
-- Date: 22.09.2026
-- Description: Idempotent Docker initialization script for Converter_UDC.
-- Source: adapted from the SSMS-generated reference script.
--
-- Safe repeat-run behavior:
--   * Database is created only when it does not exist.
--   * Schemas are created only when they do not exist.
--   * Tables are created only when they do not exist.
--   * Existing tables and their data are NOT recreated or overwritten.
--   * Demo rows are inserted only into tables created during the current run.
--   * Constraints are added only when missing.
--   * The export view is maintained with CREATE OR ALTER VIEW.
--   * Extended properties are added only to tables created during this run.
--
-- MDF/LDF storage:
--   /var/opt/mssql/udc_data/Converter_UDC.mdf
--   /var/opt/mssql/udc_data/Converter_UDC_log.ldf


/* ============================================================
   DATABASE
   ============================================================ */

USE [master]
GO

IF DB_ID(N'Converter_UDC') IS NULL
BEGIN
    PRINT 'CREATE: database Converter_UDC';

    CREATE DATABASE [Converter_UDC]
    ON PRIMARY
    (
        NAME = N'Converter_UDC',
        FILENAME = N'/var/opt/mssql/udc_data/Converter_UDC.mdf'
    )
    LOG ON
    (
        NAME = N'Converter_UDC_log',
        FILENAME = N'/var/opt/mssql/udc_data/Converter_UDC_log.ldf'
    )
    COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END
ELSE
BEGIN
    PRINT 'SKIP: database Converter_UDC already exists';
END
GO

USE [Converter_UDC]
GO


/* ============================================================
   TRACK OBJECTS CREATED DURING THIS RUN

   The temporary table survives GO batches in the same sqlcmd
   connection. It lets us seed/demo-describe only newly created
   tables and leave existing production/demo data untouched.
   ============================================================ */

IF OBJECT_ID('tempdb..#created_objects') IS NOT NULL
    DROP TABLE #created_objects;

CREATE TABLE #created_objects
(
    ObjectName sysname NOT NULL PRIMARY KEY
);
GO


/* ============================================================
   SCHEMAS
   ============================================================ */

IF SCHEMA_ID(N'audit') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [audit]');
    PRINT 'CREATE: schema audit';
END
ELSE
    PRINT 'SKIP: schema audit already exists';
GO

IF SCHEMA_ID(N'cfg') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [cfg]');
    PRINT 'CREATE: schema cfg';
END
ELSE
    PRINT 'SKIP: schema cfg already exists';
GO

IF SCHEMA_ID(N'core') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [core]');
    PRINT 'CREATE: schema core';
END
ELSE
    PRINT 'SKIP: schema core already exists';
GO

IF SCHEMA_ID(N'staging') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [staging]');
    PRINT 'CREATE: schema staging';
END
ELSE
    PRINT 'SKIP: schema staging already exists';
GO


/* ============================================================
   TABLE dbo.data_measurement
   ============================================================ */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.data_measurement', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[data_measurement](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[PatientName] [varchar](200) NOT NULL,
	[MeasurDate] [datetime2](3) NOT NULL,
	[ParameterID] [int] NOT NULL,
	[ParameterName] [varchar](200) NULL,
	[MeasurVal] [decimal](18, 6) NULL,
	[UnitCode] [varchar](32) NULL,
	[SourceSystemID] [int] NOT NULL,
	[SourceSystemName] [varchar](200) NULL,
	[ImportBatchID] [uniqueidentifier] NULL,
	[ExportBatchID] [uniqueidentifier] NULL,
	[CreateDate] [datetime2](3) NOT NULL,
	[UpdDate] [datetime2](3) NULL,
	[Comment] [varchar](1000) NULL,
	[ExpDate] [datetime2](3) NULL,
 CONSTRAINT [PK_data_measurement] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

    INSERT INTO #created_objects (ObjectName)
    VALUES (N'dbo.data_measurement');

    PRINT 'CREATE: table dbo.data_measurement';
END
ELSE
BEGIN
    PRINT 'SKIP: table dbo.data_measurement already exists';
END
GO


/* ============================================================
   TABLE dbo.data_measure_map
   ============================================================ */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.data_measure_map', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[data_measure_map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubjID] [int] NULL,
	[SubjName] [varchar](200) NULL,
	[ImpDate] [datetime2](3) NULL,
	[EventDate] [datetime2](3) NULL,
	[ExpDate] [datetime2](3) NULL,
	[ParameterID] [int] NULL,
	[ParameterName] [varchar](200) NULL,
	[DataValue] [decimal](18, 6) NULL,
	[Unit] [varchar](32) NULL,
	[Comment] [varchar](1000) NULL,
 CONSTRAINT [PK_data_measure_map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

    INSERT INTO #created_objects (ObjectName)
    VALUES (N'dbo.data_measure_map');

    PRINT 'CREATE: table dbo.data_measure_map';
END
ELSE
BEGIN
    PRINT 'SKIP: table dbo.data_measure_map already exists';
END
GO


/* ============================================================
   TABLE dbo.field_mapping_config
   ============================================================ */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.field_mapping_config', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[field_mapping_config](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Direction] [varchar](10) NULL,
	[SourceSystem] [varchar](200) NULL,
	[SourceField] [varchar](200) NULL,
	[InTargetField] [varchar](200) NULL,
	[TransformExpr] [varchar](500) NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

    INSERT INTO #created_objects (ObjectName)
    VALUES (N'dbo.field_mapping_config');

    PRINT 'CREATE: table dbo.field_mapping_config';
END
ELSE
BEGIN
    PRINT 'SKIP: table dbo.field_mapping_config already exists';
END
GO


/* ============================================================
   TABLE dbo.list_measurement_parameter
   ============================================================ */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.list_measurement_parameter', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[list_measurement_parameter](
	[ID] [int] NOT NULL,
	[ParameterName] [varchar](200) NOT NULL,
	[UnitCode] [varchar](32) NULL,
	[Description] [varchar](500) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_list_measurement_parameter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

    INSERT INTO #created_objects (ObjectName)
    VALUES (N'dbo.list_measurement_parameter');

    PRINT 'CREATE: table dbo.list_measurement_parameter';
END
ELSE
BEGIN
    PRINT 'SKIP: table dbo.list_measurement_parameter already exists';
END
GO


/* ============================================================
   VIEW dbo.vw_data_measure_map

   CREATE OR ALTER is repeat-safe and avoids the CREATE VIEW
   "already exists" error.
   ============================================================ */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_data_measure_map]
(
    SubjID,
    SubjName,
    EventDate,
    ExpDate,
    ParameterID,
    ParameterName,
    DataValue,
    Unit,
    Comment
)
AS
SELECT
    dmes.PatientID,
    CONCAT('Anonymized Patient-', dmes.PatientID),
    dmes.MeasurDate,
    SYSUTCDATETIME(),
    dmes.ParameterID,
    dmes.ParameterName,
    dmes.MeasurVal,
    dmes.UnitCode,
    dmes.Comment
FROM dbo.data_measurement AS dmes;
GO

PRINT 'OK: view dbo.vw_data_measure_map is available';
GO


/* ============================================================
   DEMO DATA

   Only seed tables that were actually created in THIS run.
   Existing tables are left completely untouched.
   ============================================================ */

IF EXISTS
(
    SELECT 1
    FROM #created_objects
    WHERE ObjectName = N'dbo.data_measure_map'
)
BEGIN
SET IDENTITY_INSERT [dbo].[data_measure_map] ON 

INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (1, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T13:59:41.5620000' AS DateTime2), CAST(N'2026-09-17T09:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(5.800000 AS Decimal(18, 6)), N'mmol/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (2, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T13:59:41.5690000' AS DateTime2), CAST(N'2026-09-17T09:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(36.700000 AS Decimal(18, 6)), N'C', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (3, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T13:59:41.5710000' AS DateTime2), CAST(N'2026-09-17T09:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(2.400000 AS Decimal(18, 6)), N'mg/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (4, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T13:59:41.5710000' AS DateTime2), CAST(N'2026-09-17T10:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(6.200000 AS Decimal(18, 6)), N'mmol/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (5, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T13:59:41.5710000' AS DateTime2), CAST(N'2026-09-17T10:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(37.200000 AS Decimal(18, 6)), N'C', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (6, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T13:59:41.5720000' AS DateTime2), CAST(N'2026-09-17T10:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(6.800000 AS Decimal(18, 6)), N'mg/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (7, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T13:59:41.5720000' AS DateTime2), CAST(N'2026-09-17T11:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(4.900000 AS Decimal(18, 6)), N'mmol/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (8, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T13:59:41.5720000' AS DateTime2), CAST(N'2026-09-17T11:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(38.100000 AS Decimal(18, 6)), N'C', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (9, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T13:59:41.5740000' AS DateTime2), CAST(N'2026-09-17T11:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(18.500000 AS Decimal(18, 6)), N'mg/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (10, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T14:02:28.9120000' AS DateTime2), CAST(N'2026-09-17T09:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(5.850000 AS Decimal(18, 6)), N'mmol/L', N'Imported CSV test')
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (11, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T14:02:28.9160000' AS DateTime2), CAST(N'2026-09-17T09:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(36.800000 AS Decimal(18, 6)), N'C', N'External source demo')
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (12, 1, N'Anonymized Patient-1', CAST(N'2026-09-18T14:02:28.9210000' AS DateTime2), CAST(N'2026-09-17T09:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(2.400000 AS Decimal(18, 6)), N'mg/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (13, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T14:02:28.9240000' AS DateTime2), CAST(N'2026-09-17T10:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(6.200000 AS Decimal(18, 6)), N'mmol/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (14, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T14:02:28.9260000' AS DateTime2), CAST(N'2026-09-17T10:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(37.200000 AS Decimal(18, 6)), N'C', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (15, 2, N'Anonymized Patient-2', CAST(N'2026-09-18T14:02:28.9260000' AS DateTime2), CAST(N'2026-09-17T10:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(6.800000 AS Decimal(18, 6)), N'mg/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (16, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T14:02:28.9260000' AS DateTime2), CAST(N'2026-09-17T11:00:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 1, N'Glucose', CAST(4.900000 AS Decimal(18, 6)), N'mmol/L', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (17, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T14:02:28.9260000' AS DateTime2), CAST(N'2026-09-17T11:05:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 2, N'Temperature', CAST(38.100000 AS Decimal(18, 6)), N'C', NULL)
INSERT [dbo].[data_measure_map] ([ID], [SubjID], [SubjName], [ImpDate], [EventDate], [ExpDate], [ParameterID], [ParameterName], [DataValue], [Unit], [Comment]) VALUES (18, 3, N'Anonymized Patient-3', CAST(N'2026-09-18T14:02:28.9280000' AS DateTime2), CAST(N'2026-09-17T11:10:00.0000000' AS DateTime2), CAST(N'2026-09-18T13:51:16.3790000' AS DateTime2), 3, N'CRP', CAST(18.500000 AS Decimal(18, 6)), N'mg/L', NULL)
SET IDENTITY_INSERT [dbo].[data_measure_map] OFF
    PRINT 'SEED: dbo.data_measure_map';
END
ELSE
BEGIN
    PRINT 'SKIP SEED: dbo.data_measure_map already existed';
END
GO


IF EXISTS
(
    SELECT 1
    FROM #created_objects
    WHERE ObjectName = N'dbo.data_measurement'
)
BEGIN
SET IDENTITY_INSERT [dbo].[data_measurement] ON 

INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (1, 1, N'patient1', CAST(N'2026-09-17T09:00:00.0000000' AS DateTime2), 1, N'Glucose', CAST(5.800000 AS Decimal(18, 6)), N'mmol/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:56:59.3200000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (2, 1, N'patient1', CAST(N'2026-09-17T09:05:00.0000000' AS DateTime2), 2, N'Temperature', CAST(36.700000 AS Decimal(18, 6)), N'C', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (3, 1, N'patient1', CAST(N'2026-09-17T09:10:00.0000000' AS DateTime2), 3, N'CRP', CAST(2.400000 AS Decimal(18, 6)), N'mg/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (4, 2, N'patient2', CAST(N'2026-09-17T10:00:00.0000000' AS DateTime2), 1, N'Glucose', CAST(6.200000 AS Decimal(18, 6)), N'mmol/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (5, 2, N'patient2', CAST(N'2026-09-17T10:05:00.0000000' AS DateTime2), 2, N'Temperature', CAST(37.200000 AS Decimal(18, 6)), N'C', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (6, 2, N'patient2', CAST(N'2026-09-17T10:10:00.0000000' AS DateTime2), 3, N'CRP', CAST(6.800000 AS Decimal(18, 6)), N'mg/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (7, 3, N'patient3', CAST(N'2026-09-17T11:00:00.0000000' AS DateTime2), 1, N'Glucose', CAST(4.900000 AS Decimal(18, 6)), N'mmol/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (8, 3, N'patient3', CAST(N'2026-09-17T11:05:00.0000000' AS DateTime2), 2, N'Temperature', CAST(38.100000 AS Decimal(18, 6)), N'C', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
INSERT [dbo].[data_measurement] ([ID], [PatientID], [PatientName], [MeasurDate], [ParameterID], [ParameterName], [MeasurVal], [UnitCode], [SourceSystemID], [SourceSystemName], [ImportBatchID], [ExportBatchID], [CreateDate], [UpdDate], [Comment], [ExpDate]) VALUES (9, 3, N'patient3', CAST(N'2026-09-17T11:10:00.0000000' AS DateTime2), 3, N'CRP', CAST(18.500000 AS Decimal(18, 6)), N'mg/L', 1, N'TestSource', NULL, NULL, CAST(N'2026-09-17T12:58:10.7560000' AS DateTime2), NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[data_measurement] OFF
    PRINT 'SEED: dbo.data_measurement';
END
ELSE
BEGIN
    PRINT 'SKIP SEED: dbo.data_measurement already existed';
END
GO


IF EXISTS
(
    SELECT 1
    FROM #created_objects
    WHERE ObjectName = N'dbo.list_measurement_parameter'
)
BEGIN
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (1, N'Glucose', N'mmol/L', N'Blood glucose concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (2, N'Temperature', N'C', N'Body temperature', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (3, N'CRP', N'mg/L', N'C-reactive protein concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (4, N'Hemoglobin', N'g/dL', N'Hemoglobin concentration in blood', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (5, N'Creatinine', N'mg/dL', N'Creatinine concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (6, N'Heart Rate', N'bpm', N'Heart rate in beats per minute', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (7, N'Oxygen Saturation', N'%', N'Peripheral oxygen saturation', 1)
    PRINT 'SEED: dbo.list_measurement_parameter';
END
ELSE
BEGIN
    PRINT 'SKIP SEED: dbo.list_measurement_parameter already existed';
END
GO


/* ============================================================
   DEFAULT CONSTRAINTS
   ============================================================ */

IF OBJECT_ID(N'dbo.DF_data_measure_map_SubjName', N'D') IS NULL
BEGIN
    ALTER TABLE [dbo].[data_measure_map]
        ADD CONSTRAINT [DF_data_measure_map_SubjName]
        DEFAULT ('Anonymized Patient') FOR [SubjName];

    PRINT 'CREATE: DF_data_measure_map_SubjName';
END
ELSE
    PRINT 'SKIP: DF_data_measure_map_SubjName already exists';
GO


IF OBJECT_ID(N'dbo.DF_data_measurement_PatientName', N'D') IS NULL
BEGIN
    ALTER TABLE [dbo].[data_measurement]
        ADD CONSTRAINT [DF_data_measurement_PatientName]
        DEFAULT ('Anonymized Patient') FOR [PatientName];

    PRINT 'CREATE: DF_data_measurement_PatientName';
END
ELSE
    PRINT 'SKIP: DF_data_measurement_PatientName already exists';
GO


IF OBJECT_ID(N'dbo.DF_data_measurement_CreateDate', N'D') IS NULL
BEGIN
    ALTER TABLE [dbo].[data_measurement]
        ADD CONSTRAINT [DF_data_measurement_CreateDate]
        DEFAULT (SYSUTCDATETIME()) FOR [CreateDate];

    PRINT 'CREATE: DF_data_measurement_CreateDate';
END
ELSE
    PRINT 'SKIP: DF_data_measurement_CreateDate already exists';
GO


IF NOT EXISTS
(
    SELECT 1
    FROM sys.default_constraints AS dc
    INNER JOIN sys.columns AS c
        ON c.object_id = dc.parent_object_id
       AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID(N'dbo.field_mapping_config')
      AND c.name = N'IsActive'
)
BEGIN
    ALTER TABLE [dbo].[field_mapping_config]
        ADD CONSTRAINT [DF_field_mapping_config_IsActive]
        DEFAULT ((1)) FOR [IsActive];

    PRINT 'CREATE: default for dbo.field_mapping_config.IsActive';
END
ELSE
    PRINT 'SKIP: default for dbo.field_mapping_config.IsActive already exists';
GO


IF OBJECT_ID(N'dbo.DF_list_measurement_parameter_IsActive', N'D') IS NULL
BEGIN
    ALTER TABLE [dbo].[list_measurement_parameter]
        ADD CONSTRAINT [DF_list_measurement_parameter_IsActive]
        DEFAULT ((1)) FOR [IsActive];

    PRINT 'CREATE: DF_list_measurement_parameter_IsActive';
END
ELSE
    PRINT 'SKIP: DF_list_measurement_parameter_IsActive already exists';
GO


/* ============================================================
   FOREIGN KEY
   ============================================================ */

IF OBJECT_ID(
    N'dbo.FK_data_measurement_measurement_parameter',
    N'F'
) IS NULL
BEGIN
    ALTER TABLE [dbo].[data_measurement]
        WITH CHECK
        ADD CONSTRAINT [FK_data_measurement_measurement_parameter]
        FOREIGN KEY ([ParameterID])
        REFERENCES [dbo].[list_measurement_parameter] ([ID]);

    PRINT 'CREATE: FK_data_measurement_measurement_parameter';
END
ELSE
BEGIN
    PRINT 'SKIP: FK_data_measurement_measurement_parameter already exists';
END
GO

ALTER TABLE [dbo].[data_measurement]
    CHECK CONSTRAINT [FK_data_measurement_measurement_parameter];
GO


/* ============================================================
   EXTENDED PROPERTIES

   The original sp_addextendedproperty calls fail on a second run
   because the properties already exist. Therefore they are run
   only for tables created during this initialization.
   ============================================================ */

IF EXISTS
(
    SELECT 1
    FROM #created_objects
    WHERE ObjectName = N'dbo.data_measure_map'
)
BEGIN
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal unique identifier of the mapping record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric identifier of the subject associated with the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'SubjID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized subject name or anonymized subject description.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'SubjName'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time when the data record was imported into the converter process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ImpDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the measurement or related event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'EventDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time when the data record was exported from the converter process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ExpDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric identifier of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ParameterID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized human-readable name of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ParameterName'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric value of the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'DataValue'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized unit of measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'Unit'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Optional standardized comment or additional information associated with the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'Comment'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores standardized measurement data fields used by the converter as an intermediate exchange structure between external data sources and the internal database model.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map'
END
ELSE
BEGIN
    PRINT 'SKIP DESCRIPTION: dbo.data_measure_map already existed';
END
GO


IF EXISTS
(
    SELECT 1
    FROM #created_objects
    WHERE ObjectName = N'dbo.data_measurement'
)
BEGIN
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal unique identifier of the measurement record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifier of the patient associated with the measurement. The value may originate from an anonymized or pseudonymized external subject identifier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'PatientID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Patient display name. If no value is supplied by the mapping process, the default value Anonymized Patient is used.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'PatientName'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the measurement or related source event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'MeasurDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifier or code of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ParameterID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Human-readable name or description of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ParameterName'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numeric value of the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'MeasurVal'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit of measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'UnitCode'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal identifier of the system or organization that supplied the data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'SourceSystemID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Human-readable name of the system or organization that supplied the data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'SourceSystemName'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier of the import batch through which the record was received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ImportBatchID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier of the export batch through which the record was sent to an external system or partner.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ExportBatchID'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was created in the converter database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'CreateDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was last updated. NULL indicates that the record has not been updated after creation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'UpdDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Optional comment or additional information associated with the measurement record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'Comment'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was exported to an external system or research partner.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ExpDate'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores measurement-related data received from external systems and research partners. Source-specific structures are converted through the mapping layer before records are stored in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement'
END
ELSE
BEGIN
    PRINT 'SKIP DESCRIPTION: dbo.data_measurement already existed';
END
GO


/* ============================================================
   FINAL VERIFICATION
   ============================================================ */

IF OBJECT_ID(N'dbo.data_measurement', N'U') IS NULL
    THROW 51001, 'Missing table: dbo.data_measurement', 1;

IF OBJECT_ID(N'dbo.data_measure_map', N'U') IS NULL
    THROW 51002, 'Missing table: dbo.data_measure_map', 1;

IF OBJECT_ID(N'dbo.field_mapping_config', N'U') IS NULL
    THROW 51003, 'Missing table: dbo.field_mapping_config', 1;

IF OBJECT_ID(N'dbo.list_measurement_parameter', N'U') IS NULL
    THROW 51004, 'Missing table: dbo.list_measurement_parameter', 1;

IF OBJECT_ID(N'dbo.vw_data_measure_map', N'V') IS NULL
    THROW 51005, 'Missing view: dbo.vw_data_measure_map', 1;

PRINT '------------------------------------------------------------';
PRINT 'OK: Converter_UDC initialization/verification completed.';
PRINT 'Existing tables were not recreated or overwritten.';
PRINT '------------------------------------------------------------';
GO

DROP TABLE #created_objects;
GO
