# Converter_2 / UDC

A small demonstration prototype for working with data import/export workflows around a Microsoft SQL Server database.

The project was developed within a limited timeframe as a technical example. All included data is synthetic and intended only for testing and demonstration.

## Current functionality

- SQL Server 2025 in Docker
- Persistent database volumes
- Database initialization / verification container
- Flask web interface
- Database table/view browser
- Export from the standardized UDC view
- Export formats:
  - CSV
  - JSON
  - XML
- CSV import test workflow
- Ready-to-use synthetic import samples
- Ready-to-use export examples
- Recent operation status for Import and Export
- Docker Compose orchestration

## Current prototype scope

### Export

Implemented for:

- CSV
- JSON
- XML

Default output directory:

```text
app/export
```

### Import

The current web prototype focuses on CSV.

Ready-to-use test files are included in:

```text
app/import
```

Example files:

```text
ClientImport_A.csv
ClientImport_B.csv
ClientImport_C.csv
```

The current web flow validates the CSV structure and data rows. Full database-write integration for the import dispatcher is still part of the planned next development stage.

## Project structure

```text
p1-2_UDC_web/
├── app/
│   ├── import/
│   ├── export/
│   ├── templates/
│   ├── utils/
│   ├── udc_web_app.py
│   ├── db_con_UDC.py
│   ├── db_view.py
│   ├── import_data.py
│   ├── export_data.py
│   └── requirements.txt
│
├── docker/
│   ├── compose.yml
│   ├── WEB_UDC/
│   │   └── Dockerfile
│   └── udc_db_init/
│       ├── Dockerfile
│       ├── init_database.sh
│       └── init_database.sql
│
└── README.md
```

## Docker services

The Docker Compose environment contains:

```text
udc_volume_init
    ↓
mssql_2025_dev
    ↓
udc_db_init
    ↓
web_udc
```

`udc_volume_init` prepares volume permissions.

`mssql_2025_dev` runs Microsoft SQL Server.

`udc_db_init` performs repeat-safe database initialization and verifies that the required UDC objects exist.

`web_udc` runs the Flask application.

## Required database objects

The current prototype expects:

```text
dbo.data_measurement
dbo.data_measure_map
dbo.field_mapping_config
dbo.list_measurement_parameter
dbo.vw_data_measure_map
```

## Configuration

Passwords and environment-specific settings must not be committed to Git.

The Docker environment expects values such as:

```text
MSSQL_SA_PASSWORD
UDC_VOLUME_NAME
```

Store them in a local `.env` file.

The `.env` file is excluded through `.gitignore`.

## Build the web image

From the project root:

```bash
docker build -f docker/WEB_UDC/Dockerfile -t web_udc:latest .
```

## Start the environment

From the `docker` directory:

```bash
docker compose config
docker compose up -d
docker compose ps -a
```

To recreate only the web container after rebuilding the image:

```bash
docker compose up -d --force-recreate web_udc
```

## Web interface

After startup:

```text
http://localhost:5000
```

Available sections:

```text
Home
DB View
Export
Import
About
```

## Test data

All data included with this repository is synthetic.

It does not contain real patient, clinical, or production data.

The import samples intentionally use clearly identifiable test values so that they can be distinguished from export examples.

## Development note

This application is an early demonstration prototype rather than a production-ready system.

If development is continued, planned areas include:

- full CSV-to-database import integration
- extended transformation and field mapping
- stronger validation
- improved error handling
- additional automated tests
- further user-interface refinement

To accelerate development within the available timeframe, an AI coding agent was used for selected implementation, refactoring and development-support tasks.

At the same time, the overall architecture, backend development and application logic, database design, integration decisions, Docker-based environment, testing and final technical review remained under my responsibility as the backend developer of the project.

## Author

LiR
