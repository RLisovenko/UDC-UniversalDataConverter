-- Author: R.Lisovenko
-- Date: 18.09.2026
-- Description: Rename the development database to Converter_UDC.

USE master;
GO

ALTER DATABASE OLD_NAME_ConverterDB
MODIFY NAME = Converter_UDC;
GO