````markdown

\# Universal Data Converter



Universal Data Converter is a backend-oriented data integration project designed to transform heterogeneous source data into a standardized internal structure and prepare it for export to external systems, research partners, or other databases.



The project is currently being developed as a practical portfolio project using Python and Microsoft SQL Server.



\## Project Goal



The main goal is to build a flexible converter that can:



\- read data from different sources;

\- transform source-specific structures into a standardized format;

\- validate incoming and outgoing data;

\- anonymize sensitive subject information;

\- export data into different formats or external systems;

\- support reverse import and data synchronization;

\- keep the architecture extendable for future adapters and automation.



\## Current Architecture



```text

Source Data

&#x20;   |

&#x20;   v

Microsoft SQL Server

&#x20;   |

&#x20;   v

dbo.data\_measurement

&#x20;   |

&#x20;   v

dbo.vw\_data\_measure\_map

&#x20;   |

&#x20;   v

Standardized Data Structure

&#x20;   |

&#x20;   v

Python Backend

&#x20;   |

&#x20;   +--> CSV

&#x20;   +--> JSON

&#x20;   +--> XML

&#x20;   +--> SQL

&#x20;   +--> API

````



\## Database



Development database:



```text

DE\_OL\_Klinikum\_ConverterDB

```



\### dbo.data\_measurement



Main internal table containing measurement data.



Important fields:



```text

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

CreateDate

UpdDate

Comment

ExpDate

```



Example measurement parameters currently used for testing:



```text

Glucose

Temperature

CRP

```



\## Standardized Export View



The view



```text

dbo.vw\_data\_measure\_map

```



transforms the internal database structure into a standardized exchange structure.



Current mapping:



```text

PatientID       -> SubjID

PatientID       -> Anonymized SubjName

MeasurDate      -> EventDate

Current UTC     -> ExpDate

ParameterID     -> ParameterID

ParameterName   -> ParameterName

MeasurVal       -> DataValue

UnitCode        -> Unit

Comment         -> Comment

```



Example anonymization:



```text

PatientID = 1

```



becomes:



```text

Anonymized Patient-1

```



The real patient name is not exported by default.



\## Planned Export Options



The future backend interface should allow explicit selection of exported fields.



Example:



```text

☐ PatientID

☐ Real PatientName

☑ Anonymized PatientName

☑ EventDate

☑ ParameterName

☑ DataValue

☑ Unit

☑ Comment

```



Real patient names should only be included when explicitly enabled.



\## Current Test Data



The current SQL test dataset contains:



```text

3 patients

3 measurement parameters per patient

9 measurement records

```



The test data is used to verify:



\* SQL mapping;

\* anonymization;

\* standardized field names;

\* data types;

\* export structure;

\* future Python database access.



\## Project Structure



```text

p1\_Universal-Data-Converter/

│

├── backend/

│

├── docs/

│

├── Sql/

│

├── .gitignore

├── README.md

├── readme.txt

└── requirements.txt

```



\## Technologies



\### Backend



```text

Python 3.12+

pyodbc

```



\### Database



```text

Microsoft SQL Server

T-SQL

ODBC Driver for SQL Server

```



\### Development Tools



```text

SQL Server Management Studio

Git

GitHub

Visual Studio Code / PyCharm

```



\## Planned Backend Development



The next development stage is the Python backend.



Initial backend milestones:



```text

1\. Connect Python to Microsoft SQL Server

2\. Read data from dbo.vw\_data\_measure\_map

3\. Convert database records into internal Python structures

4\. Validate records

5\. Export data to CSV

6\. Export data to JSON

7\. Export data to XML

8\. Implement reverse import

9\. Add logging and error handling

10\. Add configurable field selection

```



\## Future Development



Possible future extensions:



\* configurable source adapters;

\* CSV import;

\* JSON import;

\* XML import;

\* SQL-to-SQL transfer;

\* REST API integration;

\* SFTP import/export;

\* automated folder monitoring;

\* scheduled processing;

\* email-based data intake;

\* batch processing;

\* import/export history;

\* validation rules;

\* configurable mapping;

\* research database integration;

\* monitoring and logging.



\## Development Status



Current status:



```text

Database structure        Completed

Test data                 Completed

SQL mapping               Completed

Anonymized export VIEW    Completed

Python backend            Next stage

Export adapters           Planned

Reverse import            Planned

Automation                Planned

```



\## Notes



The current project uses synthetic test data only.



The database structure and test identifiers are intended for development and demonstration purposes.



Sensitive or real patient data should not be stored in the public repository.



```

```



