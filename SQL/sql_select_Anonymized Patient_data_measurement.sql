SELECT
    dc.name AS ConstraintName,
    c.name AS ColumnName,
    dc.definition AS DefaultValue
FROM sys.default_constraints dc
JOIN sys.columns c
    ON dc.parent_object_id = c.object_id
   AND dc.parent_column_id = c.column_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.data_measure_map')
  AND c.name = 'SubjName';