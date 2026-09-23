# UniversalDataConverter — Live Demo

Run the `2_UDC_web` application in GitHub Codespaces and share a public HTTPS link.

Visitors do not need to install software, clone the repository, run commands, or sign in to GitHub. GitHub may display a **Continue** confirmation on the first visit.

## Live demo

[Open UniversalDataConverter — Live Demo](https://ominous-sniffle-jrr7qpg9pv9cjqqj-5000.app.github.dev/)
On your first visit, GitHub may display a “Codespaces Access Port” notice.
Click **Continue** to open the demo. No GitHub sign-in is required.

After restarting the Codespace, set port 5000 visibility to Public again.
Keep SQL Server port 14330 Private.
Verify the demo link in an incognito window before sharing it.

The link works while the Codespace and application are running. It is a demonstration environment, not permanent hosting.

## Project structure

```text
UDC-UniversalDataConverter/
├── .devcontainer/
│   └── devcontainer.json
├── 1_udc/
├── 2_UDC_web/
│   ├── app/
│   └── docker/
│       ├── compose.yml
│       ├── SQL_SEVER_2025/
│       ├── udc_db_init/
│       └── web_udc/
├── 3_UDC_Codespaces/
│   └── README.md
├── README.md
├── readme.txt
└── .gitignore
```

Folder names are case-sensitive on Linux. Keep the existing spelling `SQL_SEVER_2025`.

## Local preparation

Run local commands from the repository root in Git Bash.
Docker Desktop must be running for image builds.

### Step 1. Configure the SQL Server image build

File: `2_UDC_web/docker/compose.yml`

Under `mssql_2025_dev`, add `build` and keep the image name:

```yaml
    # Build the SQL Server image from the repository.
    build:
      context: ./SQL_SEVER_2025
      dockerfile: Dockerfile
    image: mssql_2025_dev:latest
```

- `build`: tells Compose how to build the image.
- `context`: build directory, relative to `compose.yml`.
- `dockerfile`: build instructions inside that directory.
- `image`: name assigned to the resulting image.

Keep all other service settings.

The existing SQL Server Dockerfile uses:

```dockerfile
FROM mcr.microsoft.com/mssql/server:2025-latest
```

Validate and build:

```bash
docker compose -f 2_UDC_web/docker/compose.yml config --quiet
docker compose -f 2_UDC_web/docker/compose.yml build mssql_2025_dev
```

Check the image:

```bash
docker image inspect mssql_2025_dev:latest --format '{{.RepoTags}}'
```

Expected:

```text
[mssql_2025_dev:latest]
```

A build creates an image; it does not replace running containers.

### Step 2. Configure the database initialization image build

File: `2_UDC_web/docker/compose.yml`

Under `udc_db_init`, use:

```yaml
    # Build the database initialization image.
    build:
      context: ./udc_db_init
      dockerfile: Dockerfile
    image: udc_db_init:latest
```

This build context contains the Dockerfile and initialization scripts.

The existing initialization Dockerfile starts with:

```dockerfile
FROM mssql_2025_dev:latest
```

Therefore, build `mssql_2025_dev` before `udc_db_init`.
Service `depends_on` settings govern startup, not image build order.

Validate and build:

```bash
docker compose -f 2_UDC_web/docker/compose.yml config --quiet
docker compose -f 2_UDC_web/docker/compose.yml build udc_db_init
```

Expected: `Image udc_db_init:latest Built`.

This does not execute database initialization.

### Step 3. Configure the web application image build

File: `2_UDC_web/docker/compose.yml`

Under `web_udc`, use:

```yaml
    # Build the Flask application image.
    build:
      context: ..
      dockerfile: docker/web_udc/Dockerfile
    image: web_udc:latest
```

The build context is `2_UDC_web`, one directory above `compose.yml`.

The web Dockerfile contains:

```dockerfile
COPY app/requirements.txt /app/requirements.txt
COPY app/ /app/
```

These source paths are relative to the build context, so the context must contain the `app` directory.

Validate and build:

```bash
docker compose -f 2_UDC_web/docker/compose.yml config --quiet
docker compose -f 2_UDC_web/docker/compose.yml build web_udc
```

Expected: `Image web_udc:latest Built`.

### Step 4. Require the password and provide a default volume name

File: `2_UDC_web/docker/compose.yml`

In all three services—`mssql_2025_dev`, `udc_db_init`, and `web_udc`—use:

```yaml
      MSSQL_SA_PASSWORD: ${MSSQL_SA_PASSWORD:?Set MSSQL_SA_PASSWORD before starting UDC}
```

- Compose reads the value from the environment or `.env`.
- `:?` stops configuration processing when the value is missing or empty.
- The text after `:?` is the error message.

In the top-level `volumes` section, use:

```yaml
  db_udc:
    name: ${UDC_VOLUME_NAME:-udc_db_data}
```

- An existing `UDC_VOLUME_NAME` value is preserved.
- `:-udc_db_data` supplies the default when the value is missing or empty.

Validate:

```bash
docker compose -f 2_UDC_web/docker/compose.yml config --quiet
```

Keep the local password in `2_UDC_web/docker/.env`.
Do not commit `.env` or put the actual password in `compose.yml`.

Use `--quiet` when validating to avoid printing resolved secret values.

### Step 5. Add the Codespaces secret

This step is performed in GitHub account settings.

1. Open **Settings → Codespaces**.
2. In **Secrets**, select **New secret**.
3. Enter:

   ```text
   Name: MSSQL_SA_PASSWORD
   Value: your demo database password
   ```

4. Grant repository access to:

   ```text
   RLisovenko/UDC-UniversalDataConverter
   ```

5. Click **Add secret**.

Enter only the password in Value, without `MSSQL_SA_PASSWORD=` or surrounding quotes.

Use a strong password with uppercase and lowercase letters, numbers, and punctuation such as `!` or `-`. Avoid semicolons because the current application inserts the password into an ODBC connection string.

This is the SQL Server `sa` password, not a website visitor password.

A new Codespace database can use a different password from the local database. SQL Server and both application services receive the same secret.

Changing the secret later does not automatically change the password stored in an existing SQL Server database volume.

### Step 6. Create the Codespaces configuration

Create `.devcontainer/devcontainer.json` in the repository root:

```json
{
  "name": "UniversalDataConverter — Live Demo",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:4": {}
  },
  "forwardPorts": [5000],
  "portsAttributes": {
    "5000": {
      "label": "UniversalDataConverter — Live Demo",
      "onAutoForward": "notify"
    }
  }
}
```

Settings:

- `name`: readable development environment name.
- `image`: Ubuntu development environment.
- `features`: additional environment tools.
- `docker-in-docker:4`: Docker and Compose inside the Codespace.
- `{}`: default feature options.
- `forwardPorts`: forwards application port 5000.
- `portsAttributes`: presentation settings for forwarded ports.
- `label`: readable name shown beside port 5000.
- `onAutoForward`: displays a notification when the port is forwarded.

Port forwarding alone does not make the port public.
This configuration does not automatically start the application.

Save the file as UTF-8.

Validate from local Git Bash using Windows PowerShell:

```bash
powershell.exe -NoProfile -Command "Get-Content -Raw -Encoding UTF8 -LiteralPath '.devcontainer/devcontainer.json' -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop | ConvertTo-Json -Depth 10"
```

Expected: formatted JSON without errors.

Explicit UTF-8 avoids incorrectly displaying the dash in the demo name.
This validates JSON syntax; Codespace creation validates the environment build.

### Step 7. Review changes and verify that .env is excluded

```bash
git status --short
git --no-pager diff -- 2_UDC_web/docker/compose.yml
git check-ignore -v 2_UDC_web/docker/.env
git ls-files -- 2_UDC_web/docker/.env
```

Expected:

- `check-ignore` displays the rule excluding `.env`.
- `ls-files` produces no output for `.env`.

An ignore rule alone is insufficient if a file was already tracked.

`--no-pager` prints output directly in the terminal.
If Git opens the `less` viewer, press `q` to exit. If a search is active, press Escape first.

Backup files such as `xxxcompose copy.yml` were kept unchanged and were not included in the configuration commit.

### Step 8. Commit and push the configuration

Stage only the two configuration files:

```bash
git add -- .devcontainer/devcontainer.json 2_UDC_web/docker/compose.yml
git diff --cached --name-only
```

Confirm the staged list:

```text
.devcontainer/devcontainer.json
2_UDC_web/docker/compose.yml
```

Commit:

```bash
git commit -m "2309.2026:Configure Codespaces environment and Docker builds"
```

Our initial push was rejected with `fetch first` because GitHub contained a newer README commit.

We inspected the remote changes:

```bash
git fetch origin
git --no-pager log --oneline --left-right main...origin/main
git --no-pager diff --stat main origin/main
```

- `<`: local-only commit.
- `>`: remote-only commit.
- `diff --stat`: summary of differences; it does not modify files.

We applied the local configuration commit on top of the remote history:

```bash
git rebase origin/main
```

The rebase completed without conflicts. If a conflict occurs during another run, resolve it before continuing.

Push and configure branch tracking:

```bash
git push -u origin main
git status -sb
```

Expected:

```text
## main...origin/main
```

No `ahead` or `behind` indicator should remain.
Untracked backup and documentation files may still be listed.

The configuration was successfully pushed in commit `5d2ab1f`.
No force push was used.

## GitHub Codespaces setup

### Step 9. Create and check the Codespace

1. Open the repository on GitHub.
2. Select **Code → Codespaces → … → New with options**.
3. Choose:
   - Branch: `main`
   - Configuration: `UniversalDataConverter — Live Demo`
   - Region: `Europe West`
   - Machine type: `2-core`
4. Click **Create codespace**.
5. Wait for the browser editor to open.
6. If prompted for this repository, select **Trust Folder & Continue**.
7. Open **☰ → Terminal → New Terminal**.

The panel labelled “Describe what to…” is an agent chat, not the terminal.

Run the following commands in the Codespace terminal, not local Git Bash:

```bash
docker version --format 'Client: {{.Client.Version}} | Server: {{.Server.Version}}'
docker compose version
test -n "$MSSQL_SA_PASSWORD" && echo "Password is configured" || echo "Password is missing"
```

Expected:

- Docker client and server versions.
- Docker Compose version.
- `Password is configured`.

The password check does not print its value.

If terminal paste does not work, focus the terminal and try Ctrl+Shift+V. A browser request for local font access is unrelated to clipboard access.

### Step 10. Build the images inside Codespaces

Local Docker images are not transferred to Codespaces.

From the repository root in the Codespace terminal, validate:

```bash
docker compose -f 2_UDC_web/docker/compose.yml config --quiet
```

Build in this order. Wait for each command to succeed:

```bash
docker compose -f 2_UDC_web/docker/compose.yml build mssql_2025_dev
```

```bash
docker compose -f 2_UDC_web/docker/compose.yml build udc_db_init
```

```bash
docker compose -f 2_UDC_web/docker/compose.yml build web_udc
```

Verify all images:

```bash
docker image inspect mssql_2025_dev:latest udc_db_init:latest web_udc:latest --format '{{.RepoTags}}'
```

Expected:

```text
[mssql_2025_dev:latest]
[udc_db_init:latest]
[web_udc:latest]
```

Issue encountered during setup:

The initialization build initially failed with:

```text
pull access denied for mssql_2025_dev
```

The SQL Server image was missing from the Codespace.

We checked:

```bash
docker image inspect mssql_2025_dev:latest --format '{{.RepoTags}}'
```

After building `mssql_2025_dev` first, the initialization build succeeded. No Dockerfile change was required.

### Step 11. Start the services

```bash
docker compose -f 2_UDC_web/docker/compose.yml up -d --no-build
```

- `up`: creates and starts the services.
- `-d`: runs them in the background.
- `--no-build`: uses the images already built.

Compose prepares the volume, starts SQL Server, initializes the database, and starts Flask.

Check:

```bash
docker compose -f 2_UDC_web/docker/compose.yml ps -a
```

Expected:

| Service | State |
|---|---|
| udc_volume_init | Exited (0) |
| mssql_2025_dev | Up, healthy |
| udc_db_init | Exited (0) |
| web_udc | Up |

`Exited (0)` is expected for the two one-time initialization services.

### Step 12. Verify the application database connection

```bash
curl --fail-with-body -sS --max-time 30 http://localhost:5000/db-status
```

This calls Flask, which checks its connection to SQL Server.

Expected:

```json
{
  "database": "Converter_UDC",
  "server": "mssql_2025_dev,1433",
  "status": "Connected"
}
```

Field order may differ.

The `Connected` response was confirmed during setup.

### Step 13. Enable the public demo link

1. Open the **Ports** tab beside Terminal.
2. Find port **5000**, labelled:
   `UniversalDataConverter — Live Demo`.
3. Right-click the row.
4. Select **Port Visibility → Public**.
5. Leave SQL Server port **14330** private.
6. Copy the **Forwarded Address** for port 5000.
7. Open it in an incognito browser window.

Use the actual address provided by Codespaces:

```text
https://<codespace-name>-5000.app.github.dev/
```

Do not manually replace the generated hostname with the project name.

Current demo:

https://ominous-sniffle-jrr7qpg9pv9cjqqj-5000.app.github.dev/

Confirmed behavior:

- The application opens without GitHub sign-in.
- GitHub displays a Continue confirmation on the first visit.

Use a readable link label when sharing:

[UniversalDataConverter — Live Demo](https://ominous-sniffle-jrr7qpg9pv9cjqqj-5000.app.github.dev/)

Changing the environment name or port label does not rename the generated URL.

### Step 14. Verify the demonstration features

Perform these checks through the public link in an incognito window:

- [ ] Home displays the connected database status.
- [ ] DB View displays rows from a selected table or view.
- [ ] Export downloads a CSV file.
- [ ] Export downloads a JSON file.
- [ ] Export downloads an XML file.
- [ ] Import successfully validates a supplied test CSV.
- [ ] About opens correctly.

The current web import validates CSV files.
Database-write integration is not connected in this prototype.

These feature checks remain to be confirmed.

## Confirmed result

- Docker images build inside Codespaces.
- SQL Server is healthy.
- Database initialization finishes with exit code 0.
- Flask is running on port 5000.
- Flask connects to Converter_UDC.
- The public link opens without GitHub authentication.
- A first-visit Continue confirmation is displayed.

No UI, Python application logic, SQL schema, or import/export logic was changed for this setup.

## Availability

The demo requires a running Codespace and application.

Stopping the Codespace, reaching an idle timeout, or exhausting the available quota can interrupt access. Visitors cannot start the environment themselves.

Before sending the link, confirm that the Codespace is running and test the public URL again.

The generated URL is tied to this Codespace. Creating a replacement Codespace produces a different URL.

## Documentation status

The configuration files have been committed and pushed.
This README is prepared for manual saving and a separate documentation commit.