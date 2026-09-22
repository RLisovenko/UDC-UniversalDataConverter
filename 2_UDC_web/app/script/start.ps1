# Author: R.Lisovenko
# Date: 22.09.2026
# Description: Creates and activates the local virtual environment for the current project.

$ErrorActionPreference = "Stop"

# Directory where this script is located.
$ScriptDir = $PSScriptRoot

# Project directory is one level above the script directory.
$ProjectDir = Split-Path -Parent $ScriptDir

# Base Python used to create the project virtual environment.
$BasePython = "C:\dev_soft\Anaconda3_2023\python.exe"

# Project virtual environment directory.
$VenvPath = Join-Path $ProjectDir ".venv"

Set-Location $ProjectDir

# Create the virtual environment only if it does not already exist.
if (-not (Test-Path $VenvPath)) {
    Write-Host "Creating virtual environment: $VenvPath"
    & $BasePython -m venv $VenvPath
}
else {
    Write-Host "Virtual environment already exists: $VenvPath"
}

# Activate the virtual environment.
$ActivateScript = Join-Path $VenvPath "Scripts\Activate.ps1"
. $ActivateScript

Write-Host ""
Write-Host "Current project virtual environment activated."
Write-Host "Python:"
python --version

Write-Host ""
Write-Host "Python executable:"
python -c "import sys; print(sys.executable)"