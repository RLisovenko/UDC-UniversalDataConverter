param([ValidateSet('Setup','Local','Tunnel','All')][string]$Mode='Local')
$ErrorActionPreference='Stop'
$projectDir=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$compose=Join-Path $projectDir 'docker\compose.yml'
function Invoke-Compose {
    & docker compose -f $compose @args
    if ($LASTEXITCODE -ne 0) { throw 'Docker Compose failed. See output above.' }
}
function Wait-Web {
    $deadline=(Get-Date).AddMinutes(3)
    do {
        try {
            $result=Invoke-RestMethod -Uri 'http://127.0.0.1:5000/db-status' -TimeoutSec 10
            if ($result.status -eq 'Connected' -and $result.database -eq 'Converter_UDC') {
                Write-Host 'OK: Converter_UDC is Connected.'
                return
            }
        } catch { }
        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $deadline)
    throw 'Database connection check failed at http://localhost:5000/db-status.'
}
function Wait-Database {
    Write-Host 'Waiting for SQL Server and existing Converter_UDC database (up to 5 minutes)...'
    $deadline=(Get-Date).AddMinutes(5)
    # A fresh installation has no UDC database yet; initialization creates it later.
    # An existing database must accept a real connection before initialization starts.
    $probe='SET NOCOUNT ON; IF DB_ID(N''Converter_UDC'') IS NOT NULL BEGIN IF ISNULL(HAS_DBACCESS(N''Converter_UDC''),0) <> 1 THROW 51000, ''Database is not ready'', 1; EXEC(N''USE [Converter_UDC]; SELECT 1;''); END ELSE SELECT 1;'
    do {
        # Feed SQL on stdin to avoid Windows PowerShell 5.1 native argument quoting.
        # The password stays inside the container, in sqlcmd's supported environment variable.
        $savedPreference=$ErrorActionPreference
        try {
            $ErrorActionPreference='Continue'
            $result = $probe | & docker compose -f $compose exec -T mssql_2025_dev sh -c 'export SQLCMDPASSWORD=$MSSQL_SA_PASSWORD; exec /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b -l 5 -t 5' 2>&1
            $probeExit=$LASTEXITCODE
        } finally { $ErrorActionPreference=$savedPreference }
        if ($probeExit -eq 0) {
            Write-Host 'OK: SQL Server is ready; existing UDC database is accessible.'
            return
        }
        Start-Sleep -Seconds 3
    } while ((Get-Date) -lt $deadline)
    throw 'SQL/UDC readiness timed out. Inspect SQL Server logs; initialization was not started.'
}
try {
    if ($Mode -in @('Tunnel','All')) {
        if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) { throw 'Install cloudflared and reopen this script.' }
    }
    if ($Mode -ne 'Tunnel') {
        if (-not (Test-Path -LiteralPath $compose)) { throw 'Place this complete package in 2_UDC_web\script\deployment.' }
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop first.' }
        & docker info *> $null
        if ($LASTEXITCODE -ne 0) {
            $desktop=Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
            if (-not (Test-Path -LiteralPath $desktop)) { throw 'Start Docker Desktop manually, then retry.' }
            Start-Process -FilePath $desktop -WindowStyle Hidden
            $deadline=(Get-Date).AddMinutes(3)
            do {
                Start-Sleep -Seconds 3
                & docker info *> $null
                if ($LASTEXITCODE -eq 0) { break }
            } while ((Get-Date) -lt $deadline)
            if ($LASTEXITCODE -ne 0) { throw 'Docker Desktop did not become ready. Check its installation and Linux container mode.' }
        }
        Push-Location (Split-Path -Parent $compose)
        try {
            Invoke-Compose config --quiet
            if ($Mode -eq 'Setup') {
                Invoke-Compose pull udc_volume_init
                foreach ($service in @('mssql_2025_dev','udc_db_init','web_udc')) {
                    Invoke-Compose build $service
                }
            }
            # Compose prepares volumes, waits for SQL health and runs DB initialization.
            # No volume deletion; existing data is retained by the project's init script.
            Invoke-Compose up -d --no-build --pull never mssql_2025_dev
            Wait-Database
            Invoke-Compose up -d --no-build --pull never
            Wait-Web
            Invoke-Compose ps -a
        } finally { Pop-Location }
        Write-Host 'Local URL: http://localhost:5000'
        Start-Process 'http://localhost:5000'
    } else { Wait-Web }
    if ($Mode -in @('Tunnel','All')) {
        Write-Host 'Public demo: anyone with the generated URL can access the application.'
        Write-Host 'Keep this window open. Ctrl+C stops the tunnel; Docker stays running.'
        & cloudflared tunnel --url http://127.0.0.1:5000
        if ($LASTEXITCODE -ne 0) { throw 'Cloudflare tunnel stopped with an error. See output above.' }
    }
    exit 0
} catch {
    Write-Host ('ERROR: '+$_.Exception.Message) -ForegroundColor Red
    Write-Host 'No containers or volumes were deleted. For a fresh install, follow INSTALL_UDC_2.md and run install_udc_2.cmd.'
    exit 1
}
