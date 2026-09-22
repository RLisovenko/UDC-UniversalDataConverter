@echo off
setlocal

REM Author: R.Lisovenko
REM Date: 22.09.2026
REM Description: Configures PowerShell script execution and unblocks start.ps1.

set "START_SCRIPT=%~dp0start.ps1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$currentUserPolicy = Get-ExecutionPolicy -Scope CurrentUser; ^
if ($currentUserPolicy -ne 'RemoteSigned') { ^
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue; ^
} ^
$currentUserPolicy = Get-ExecutionPolicy -Scope CurrentUser; ^
Unblock-File -LiteralPath '%START_SCRIPT%' -ErrorAction SilentlyContinue; ^
Write-Host ''; ^
Write-Host ('CurrentUser policy : ' + $currentUserPolicy); ^
Write-Host ('Effective policy   : ' + (Get-ExecutionPolicy)); ^
Write-Host ''; ^
if ($currentUserPolicy -eq 'RemoteSigned') { ^
    Write-Host 'PowerShell CurrentUser policy configured.'; ^
} else { ^
    Write-Warning ('CurrentUser policy is: ' + $currentUserPolicy); ^
} ^
Write-Host 'start.ps1 was unblocked.'"

echo.
echo Setup finished.