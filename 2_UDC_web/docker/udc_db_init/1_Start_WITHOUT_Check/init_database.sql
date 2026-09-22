-- Author: R.Lisovenko
-- Date: 21.09.2026
-- Description: Docker initialization script for the Converter_UDC demo database.
-- Source: adapted from the SSMS-generated reference script.
-- Note: physical MDF/LDF paths are intentionally omitted so SQL Server uses
--       the container's default database storage location.

USE [master]
GO

IF DB_ID(N'Converter_UDC') IS NULL
BEGIN
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
GO

USE [Converter_UDC]
GO
/****** Object:  Schema [audit]    Script Date: 9/21/2026 11:08:37 AM ******/
CREATE SCHEMA [audit]
GO
/****** Object:  Schema [cfg]    Script Date: 9/21/2026 11:08:37 AM ******/
CREATE SCHEMA [cfg]
GO
/****** Object:  Schema [core]    Script Date: 9/21/2026 11:08:37 AM ******/
CREATE SCHEMA [core]
GO
/****** Object:  Schema [staging]    Script Date: 9/21/2026 11:08:37 AM ******/
CREATE SCHEMA [staging]
GO
/****** Object:  Table [dbo].[data_measurement]    Script Date: 9/21/2026 11:08:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.data_measurement', 'U') IS NULL
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
GO
/****** Object:  View [dbo].[vw_data_measure_map]    Script Date: 9/21/2026 11:08:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
    VIEW does not store data physically.
    It shows transformed data from dbo.data_measurement
    in the standardized export structure.
*/

CREATE   VIEW [dbo].[vw_data_measure_map]
(
    SubjID,         -- Standardized subject identifier
    SubjName,       -- Anonymized subject name
    EventDate,      -- Date/time when the measurement occurred
    ExpDate,        -- Current UTC time when the VIEW is queried
    ParameterID,    -- Measurement parameter identifier
    ParameterName,  -- Measurement parameter name
    DataValue,      -- Measurement value
    Unit,           -- Measurement unit
    Comment         -- Optional comment
)
AS
SELECT
    dmes.PatientID,     -- PatientID is mapped to the standardized subject ID
    CONCAT('Anonymized Patient-', dmes.PatientID),-- Real patient name is not exported.Example: PatientID = 1 -> "Anonymized Patient 1"
    dmes.MeasurDate,    -- Original measurement date/time
    SYSUTCDATETIME(),   -- UTC date/time when data is read from the VIEW
    dmes.ParameterID,   -- Parameter fields are transferred directly
    dmes.ParameterName, -- Parameter fields are transferred directly
    dmes.MeasurVal,     -- Internal MeasurVal is renamed to standardized DataValue
    dmes.UnitCode,      -- Internal UnitCode is renamed to standardized Unit
    dmes.Comment        -- Optional comment. On reverse import, an incoming comment can be merged/appendedwith the existing internal comment instead of replacing it.
FROM dbo.data_measurement AS dmes;
GO
/****** Object:  Table [dbo].[data_measure_map]    Script Date: 9/21/2026 11:08:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  Table [dbo].[field_mapping_config]    Script Date: 9/21/2026 11:08:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  Table [dbo].[list_measurement_parameter]    Script Date: 9/21/2026 11:08:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
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
GO
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
GO
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (1, N'Glucose', N'mmol/L', N'Blood glucose concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (2, N'Temperature', N'C', N'Body temperature', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (3, N'CRP', N'mg/L', N'C-reactive protein concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (4, N'Hemoglobin', N'g/dL', N'Hemoglobin concentration in blood', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (5, N'Creatinine', N'mg/dL', N'Creatinine concentration', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (6, N'Heart Rate', N'bpm', N'Heart rate in beats per minute', 1)
INSERT [dbo].[list_measurement_parameter] ([ID], [ParameterName], [UnitCode], [Description], [IsActive]) VALUES (7, N'Oxygen Saturation', N'%', N'Peripheral oxygen saturation', 1)
GO
ALTER TABLE [dbo].[data_measure_map] ADD  CONSTRAINT [DF_data_measure_map_SubjName]  DEFAULT ('Anonymized Patient') FOR [SubjName]
GO
ALTER TABLE [dbo].[data_measurement] ADD  CONSTRAINT [DF_data_measurement_PatientName]  DEFAULT ('Anonymized Patient') FOR [PatientName]
GO
ALTER TABLE [dbo].[data_measurement] ADD  CONSTRAINT [DF_data_measurement_CreateDate]  DEFAULT (sysutcdatetime()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[field_mapping_config] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[list_measurement_parameter] ADD  CONSTRAINT [DF_list_measurement_parameter_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[data_measurement]  WITH CHECK ADD  CONSTRAINT [FK_data_measurement_measurement_parameter] FOREIGN KEY([ParameterID])
REFERENCES [dbo].[list_measurement_parameter] ([ID])
GO
ALTER TABLE [dbo].[data_measurement] CHECK CONSTRAINT [FK_data_measurement_measurement_parameter]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal unique identifier of the mapping record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric identifier of the subject associated with the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'SubjID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized subject name or anonymized subject description.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'SubjName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time when the data record was imported into the converter process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ImpDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the measurement or related event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'EventDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time when the data record was exported from the converter process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ExpDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric identifier of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ParameterID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized human-readable name of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'ParameterName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized numeric value of the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'DataValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Standardized unit of measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'Unit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Optional standardized comment or additional information associated with the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores standardized measurement data fields used by the converter as an intermediate exchange structure between external data sources and the internal database model.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measure_map'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal unique identifier of the measurement record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifier of the patient associated with the measurement. The value may originate from an anonymized or pseudonymized external subject identifier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'PatientID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Patient display name. If no value is supplied by the mapping process, the default value Anonymized Patient is used.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'PatientName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the measurement or related source event.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'MeasurDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifier or code of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ParameterID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Human-readable name or description of the measured parameter.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ParameterName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numeric value of the measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'MeasurVal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit of measurement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'UnitCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Internal identifier of the system or organization that supplied the data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'SourceSystemID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Human-readable name of the system or organization that supplied the data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'SourceSystemName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier of the import batch through which the record was received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ImportBatchID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique identifier of the export batch through which the record was sent to an external system or partner.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ExportBatchID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was created in the converter database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was last updated. NULL indicates that the record has not been updated after creation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'UpdDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Optional comment or additional information associated with the measurement record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UTC date and time when the record was exported to an external system or research partner.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement', @level2type=N'COLUMN',@level2name=N'ExpDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores measurement-related data received from external systems and research partners. Source-specific structures are converted through the mapping layer before records are stored in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'data_measurement'
GO
