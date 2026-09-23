----------------перезапуск В терминале Codespaces запускает уже собранные контейнеры 
docker compose -f 2_UDC_web/docker/compose.yml up -d --no-build
docker compose -f 2_UDC_web/docker/compose.yml ps -a
-----------------Проверить подключение:
curl -sS --max-time 30 http://localhost:5000/db-status

После каждого перезапуска проверить Ports:
5000 → Public, протокол HTTP.
14330 → Private.
------------------------------------------------------------

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


----------------------------GIT

cd /c/SourceCode/Psc/UDC-UniversalDataConverter

git init
git branch -M main
git remote add origin https://github.com/RLisovenko/UDC-UniversalDataConverter.git
git fetch origin
git reset --mixed origin/main
