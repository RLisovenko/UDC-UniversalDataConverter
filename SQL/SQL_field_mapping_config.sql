-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Create the configurable field mapping table for IMPORT and EXPORT field mappings.

USE Converter_UDC;
GO
/*
    Stores configurable field mappings between external data structures
    and the standardized UDC data model.

    This table does not contain measurement data.
    It contains metadata that describes how fields from different
    external systems correspond to the internal standardized fields.

    IMPORT:
        External field -> standardized internal field

    EXPORT:
        Standardized internal field -> external field

    The configuration allows the converter to support different
    external systems without changing the canonical data structure
    of dbo.data_measure_map.
*/

CREATE TABLE dbo.field_mapping_config
(
    ID      INT IDENTITY(1,1) PRIMARY KEY,

    Direction      VARCHAR(10),     -- IMPORT / EXPORT
        -- IMPORT = external system -> UDC
        -- EXPORT = UDC -> external system
    SourceSystem   VARCHAR(200),    -- External system or data source
    SourceField    VARCHAR(200),    -- Field name in the source structure
    InTargetField    VARCHAR(200),  -- Field name in the target structure
        
    TransformExpr  VARCHAR(500) NULL,
        -- Optional transformation rule.default value or simple formula.

    IsActive       BIT DEFAULT 1
        -- 1 = mapping is active, 0 = mapping is disabled
);
GO