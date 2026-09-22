создать напрямую переменные окружения с среды по ссылке
& "C:\dev_soft\Anaconda3_2023\python.exe" -m venv .venv

разблокировать, чтоб активировать переменную
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
активировать

.\.venv\Scripts\Activate.ps1
------------------------------------------разблокировка запуска скрипта 
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Unblock-File .\script\start.ps1
# Deactivate Conda environment if it is currently active.
if ($env:CONDA_PREFIX) {
    conda deactivate
}
------------------------------------------
. .\script\start.ps1  = . + пробел + .\script\start.ps1

