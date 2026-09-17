USE Converter_UDC;
GO
/* 
    VIEW does not store data physically.
    It shows transformed data from dbo.data_measurement
    in the standardized export structure.
*/

CREATE OR ALTER VIEW dbo.vw_data_measure_map
(
    SubjID,         -- Standardized subject identifier
    SubjName,       -- Anonymized subject name or real name
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

SELECT *
FROM dbo.vw_data_measure_map
ORDER BY SubjID, EventDate, ParameterID;
GO