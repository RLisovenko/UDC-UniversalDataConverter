INSERT INTO dbo.data_measure_map
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
SELECT
    dmes.PatientID,
    CONCAT('Anonymized Patient ', dmes.PatientID),
    dmes.MeasurDate,
    SYSUTCDATETIME(),
    dmes.ParameterID,
    dmes.ParameterName,
    dmes.MeasurVal,
    dmes.UnitCode,
    dmes.Comment
FROM dbo.data_measurement AS dmes;
GO