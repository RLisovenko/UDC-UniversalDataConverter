@echo off
setlocal EnableExtensions DisableDelayedExpansion
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0udc.ps1" -Mode Local
set "UDC_EXIT=%ERRORLEVEL%"
pause
exit /b %UDC_EXIT%
