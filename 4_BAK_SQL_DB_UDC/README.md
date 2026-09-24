# UDC Database — SQL Script and Backup

This folder contains a SQL script and a backup of the `Converter_UDC` database used by the Universal Data Converter project.

## Files

| File | Purpose |
| --- | --- |
| `Converter_NEW_UDC_full.sql` | Portable script for creating the database structure and loading the included data. Uses the SQL Server default data and log directories. |
| `Converter_UDC.bak` | Database backup for restoration through SQL Server Management Studio (SSMS). |
| `Converter_UDC_full.sql` | Original script, if retained. Contains fixed Windows file paths and server-specific settings that require adaptation before use. |

The script and backup were produced at different times and may contain different data. Choose one method below; do not execute the creation script over a restored database.

## Requirements

- A running Microsoft SQL Server instance.
- SQL Server Management Studio (SSMS).
- Permissions to create or restore a database.

The portable script can be used with SQL Server on Windows or in a Linux Docker container. It is not intended for MySQL, PostgreSQL, or SQLite. Compatibility with a particular SQL Server version should be verified before use. A backup cannot be restored to an older SQL Server version than the instance that created it.

## Option 1 — Create the Database from the Portable Script

1. Connect to the target SQL Server instance in SSMS.
2. Open `Converter_NEW_UDC_full.sql`.
3. Set the database name near the beginning of the script. For a separate test database, use:

   ```sql
   DECLARE @DatabaseName sysname = N'Converter_UDC_DemoTest';
   ```

4. Execute the entire script in one query window. SQLCMD mode is not required.
5. Refresh **Databases** in Object Explorer and check the created database.

If a database with the selected name already exists, the script stops without overwriting it. Schema creation and data loading are performed in a transaction. If initialization fails, those changes are rolled back; the newly created empty database may remain.

The script uses the server's default file locations and compatibility level. No local Windows paths need to be entered.

## Option 2 — Restore the Backup

1. Place `Converter_UDC.bak` in a directory accessible to the SQL Server service.
2. In SSMS, right-click **Databases → Restore Database…**.
3. Select **Device**, then add the backup file.
4. Set the destination database name. Use a new name such as `Converter_UDC_DemoTest` for testing.
5. On the **Files** page, check the destination data and log paths. Choose valid paths on the target SQL Server host and avoid paths belonging to another database.
6. Leave **Overwrite the existing database (WITH REPLACE)** unchecked when restoring a separate test copy.
7. Click **OK**, then refresh **Databases**.

For SQL Server running in Docker, copy the backup into the container first. For example, run the following command from the directory containing the backup:

```powershell
docker cp .\Converter_UDC.bak mssql_2025_dev:/var/opt/mssql/data/Converter_UDC.bak
```

Replace `mssql_2025_dev` if the container has a different name. In the SSMS restore dialog, select `/var/opt/mssql/data/Converter_UDC.bak`. Paths shown in that dialog belong to the SQL Server host or container, not necessarily to the computer running SSMS.

## Connect the Application

Configure the application to use the target SQL Server instance and the database name selected during creation or restoration. Creating the database does not automatically configure the application's connection or grant its account access.

## Validation

The portable script has been checked statically for preservation of the source SQL blocks. Execution on the target server must still be verified. After creation or restoration, check the database objects, application connection, database viewer, and export functionality. Test imports only against a separate test database.

-- Author: R.Lisovenko
-- Date: 24.09.2026
-- Description: General Scripts to create database
