# Database Objects Overview

This document briefly describes the role of the main database objects used by the Universal Data Converter (UDC).

The database layer is designed to separate the internal data model, standardized exchange data, external field mappings, and import/export processes.

This separation allows import and export operations to work independently and asynchronously.

---

## dbo.data_measurement

Main internal data table.

Stores measurement data in the internal database structure.

Examples of stored information:

- PatientID
- PatientName
- MeasurDate
- ParameterID
- ParameterName
- MeasurVal
- UnitCode
- SourceSystem
- Import / Export batch information
- Create / Update / Export dates
- Comment

This table represents the internal data model and should not depend on the structure of external systems.

---

## dbo.data_measure_map

Standardized intermediate exchange table.

This table represents the canonical UDC data structure used between the internal database and external systems.

Main purposes:

- intermediate storage for IMPORT data;
- intermediate storage for EXPORT data;
- separation of external formats from the internal database structure;
- preparation of data before further processing;
- support for asynchronous import and export processes;
- possibility to validate or transform data before it reaches the internal database;
- possibility to prepare export data in advance instead of generating it only at the moment of transmission.

Example standardized fields:

- SubjID
- SubjName
- ImpDate
- EventDate
- ExpDate
- ParameterID
- ParameterName
- DataValue
- Unit
- Comment

The structure should remain stable even when different external systems use completely different field names.

---

## dbo.vw_data_measure_map

Standardized export VIEW.

The VIEW transforms internal records from `dbo.data_measurement` into the standardized UDC exchange structure.

Example mapping:

```text
PatientID       -> SubjID
PatientName     -> Anonymized SubjName
MeasurDate      -> EventDate
ParameterID     -> ParameterID
ParameterName   -> ParameterName
MeasurVal       -> DataValue
UnitCode        -> Unit
Comment         -> Comment
```

The VIEW provides export-ready standardized data without modifying the original internal records.

It can be used as the first stage of the export process:

```text
dbo.data_measurement
        |
        v
dbo.vw_data_measure_map
        |
        v
dbo.data_measure_map
        |
        v
Converter / External System
```

This allows standardized export data to be prepared independently from the external transmission process.

---

## dbo.field_mapping_config

Configuration table for external field mappings.

Different external systems may use different field names and data structures.

`field_mapping_config` describes how those fields correspond to the standardized UDC fields.

Example IMPORT mapping:

```text
External field       UDC field

patient_no        -> SubjID
measurement_time  -> EventDate
result_value      -> DataValue
result_unit       -> Unit
```

Example EXPORT mapping:

```text
UDC field            External field

SubjID             -> subject_id
EventDate          -> event_time
DataValue          -> result
Unit               -> result_unit
```

The table also supports optional transformation rules and activation/deactivation of individual mappings.

This makes it possible to add new external systems without changing the canonical `data_measure_map` structure.

---

## Data Flow

### EXPORT

```text
dbo.data_measurement
        |
        v
dbo.vw_data_measure_map
        |
        v
dbo.data_measure_map
        |
        v
field_mapping_config
        |
        v
Python Converter
        |
        v
CSV / JSON / XML / SQL / API / External System
```

### IMPORT

```text
External System
        |
        v
Python Converter
        |
        v
field_mapping_config
        |
        v
dbo.data_measure_map
        |
        v
Validation / Transformation
        |
        v
dbo.data_measurement
```

---

## Design Principle

The key idea is to keep the processes independent:

```text
Internal Data
     |
     v
Canonical Exchange Layer
     |
     v
External Systems
```

`data_measurement` contains the internal data model.

`data_measure_map` is the canonical intermediate exchange layer.

`vw_data_measure_map` prepares standardized export data.

`field_mapping_config` adapts different external field structures to the canonical UDC structure.

This architecture allows import and export processes to be separated, asynchronous, configurable, and extendable.

---

*Last updated: 18.09.2026*
