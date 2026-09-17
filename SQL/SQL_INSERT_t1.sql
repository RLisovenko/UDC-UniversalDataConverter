USE Converter_UDC;
GO

INSERT INTO dbo.data_measurement
(
    PatientID,
    PatientName,
    MeasurDate,
    ParameterID,
    ParameterName,
    MeasurVal,
    UnitCode,
    SourceSystemID,
    SourceSystemName,
    Comment
)
VALUES

-- patient1
(
    1,
    'patient1',
    '2026-09-17T09:00:00.000',
    1,
    'Glucose',
    5.80,
    'mmol/L',
    1,
    'TestSource',
    NULL
),
(
    1,
    'patient1',
    '2026-09-17T09:05:00.000',
    2,
    'Temperature',
    36.70,
    'C',
    1,
    'TestSource',
    NULL
),
(
    1,
    'patient1',
    '2026-09-17T09:10:00.000',
    3,
    'CRP',
    2.40,
    'mg/L',
    1,
    'TestSource',
    NULL
),

-- patient2
(
    2,
    'patient2',
    '2026-09-17T10:00:00.000',
    1,
    'Glucose',
    6.20,
    'mmol/L',
    1,
    'TestSource',
    NULL
),
(
    2,
    'patient2',
    '2026-09-17T10:05:00.000',
    2,
    'Temperature',
    37.20,
    'C',
    1,
    'TestSource',
    NULL
),
(
    2,
    'patient2',
    '2026-09-17T10:10:00.000',
    3,
    'CRP',
    6.80,
    'mg/L',
    1,
    'TestSource',
    NULL
),

-- patient3
(
    3,
    'patient3',
    '2026-09-17T11:00:00.000',
    1,
    'Glucose',
    4.90,
    'mmol/L',
    1,
    'TestSource',
    NULL
),
(
    3,
    'patient3',
    '2026-09-17T11:05:00.000',
    2,
    'Temperature',
    38.10,
    'C',
    1,
    'TestSource',
    NULL
),
(
    3,
    'patient3',
    '2026-09-17T11:10:00.000',
    3,
    'CRP',
    18.50,
    'mg/L',
    1,
    'TestSource',
    NULL
);
GO

SELECT *
FROM dbo.data_measurement
ORDER BY PatientID, MeasurDate, ParameterID;
GO