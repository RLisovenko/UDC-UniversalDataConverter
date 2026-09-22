# Author: R.Lisovenko
# Date: 22.09.2026
# Description: Performs one-time PowerShell setup for the project scripts.

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

$StartScript = Join-Path $PSScriptRoot "start.ps1"

if (Test-Path $StartScript) {
    Unblock-File $StartScript
    Write-Host "start.ps1 was unblocked."
}

Write-Host ""
Write-Host "PowerShell setup completed."