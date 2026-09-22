ExtField	dbo.data_measurement	Смысл
SubjID		PatientID	универсальный идентификатор субъекта
SubjName	PatientName	имя/обозначение субъекта
EventDate	MeasurDate	дата события/измерения
ParameterID	ParameterID	код параметра
ParameterName	ParameterName	название параметра
Value		MeasurVal	значение
Unit		UnitCode	единица измерения
Comment		Comment	комментарий
ImpDate		CreateDate	когда запись импортирована/создана у нас
ExpDate		п	ока нет поля	когда запись экспортирована


ID
PatientID
PatientName
MeasurDate
ParameterID
ParameterName
MeasurVal
UnitCode
SourceSystemID
SourceSystemName
ImportBatchID
ExportBatchID
CreateDate       ← ImpDate
ExpDate          ← ExpDate
UpdDate
Comment

ExtField          DBField
--------------------------------
SubjID         →  PatientID
SubjName       →  PatientName
ImpDate        →  CreateDate
EventDate      →  MeasurDate
ExpDate        →  ExpDate
ParameterID    →  ParameterID
ParameterName  →  ParameterName
Value          →  MeasurVal
Unit           →  UnitCode
Comment        →  Comment
