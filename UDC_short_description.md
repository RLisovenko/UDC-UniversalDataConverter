# Universal Data Converter (UDC)

## Short Description

Universal Data Converter (UDC) is a backend-oriented prototype for bidirectional data exchange between internal SQL Server structures and external data formats.

The current implementation demonstrates a standardized intermediate data model, import/export processing, anonymized subject representation, and a simple graphical interface for controlled data exchange.

## Current Data Flow

```text
External Sources
CSV / JSON / XML / ...
        |
      IMPORT
        |
        v
Standard UDC Model
dbo.data_measure_map
        |
 validation / mapping
        |
        v
Internal SQL Server
dbo.data_measurement
        |
      EXPORT
        |
        v
CSV / JSON / XML
API / DB / Partners
```

## Current Prototype

- Microsoft SQL Server data model
- Canonical intermediate structure: `dbo.data_measure_map`
- Standardized export view: `dbo.vw_data_measure_map`
- CSV / JSON / XML export
- CSV import
- Import file selection and batch option
- Configurable export directory
- Simple GUI for import/export operations
- Anonymized subject representation
- Import timestamp handling
- Prepared field-mapping configuration structure

## Planned Extensions

- Dynamic field mapping
- Graphical field-mapping interface
- XLSX and additional formats
- Duplicate detection
- Validation rules
- ImportBatchID / ExportBatchID processing
- Sequence management for multiple data sources
- API integration
- Configurable anonymization
- Asynchronous import/export processing
- Logging and monitoring

## Prototype Status

This implementation is a functional prototype intended to demonstrate the core architecture and bidirectional data flow of the Universal Data Converter.

It is not yet a production-ready integration platform and is intended to be extended step by step.
