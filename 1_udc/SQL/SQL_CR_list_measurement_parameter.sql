-- Author: R.Lisovenko
-- Date: 21.09.2026
-- Description: Measurement parameter list with demo data and PK/FK relationship.

CREATE TABLE dbo.list_measurement_parameter
(
    ID            INT NOT NULL,
    ParameterName VARCHAR(200) NOT NULL,
    UnitCode      VARCHAR(32) NULL,
    Description   VARCHAR(500) NULL,
    IsActive      BIT NOT NULL
        CONSTRAINT DF_list_measurement_parameter_IsActive DEFAULT (1),

    CONSTRAINT PK_list_measurement_parameter
        PRIMARY KEY (ID)
);
GO


INSERT INTO dbo.list_measurement_parameter
(
    ID,
    ParameterName,
    UnitCode,
    Description
)
VALUES
    (1, 'Glucose',           'mmol/L', 'Blood glucose concentration'),
    (2, 'Temperature',       'C',      'Body temperature'),
    (3, 'CRP',               'mg/L',   'C-reactive protein concentration'),
    (4, 'Hemoglobin',        'g/dL',   'Hemoglobin concentration in blood'),
    (5, 'Creatinine',        'mg/dL',  'Creatinine concentration'),
    (6, 'Heart Rate',        'bpm',    'Heart rate in beats per minute'),
    (7, 'Oxygen Saturation', '%',      'Peripheral oxygen saturation');
GO


ALTER TABLE dbo.data_measurement
ADD CONSTRAINT FK_data_measurement_measurement_parameter
FOREIGN KEY (ParameterID)
REFERENCES dbo.list_measurement_parameter(ID);
GO