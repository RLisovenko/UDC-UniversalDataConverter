docker compose stop mssql_2025_dev
mkdir -p db_udc_view
MSYS_NO_PATHCONV=1 docker cp mssql_2025_dev:/var/opt/mssql/udc_data/. ./db_udc_view
ls -lah db_udc_view

Запускаем web_udc, временно игнорируя его зависимость от повторного udc_db_init:
docker compose up -d --no-deps --force-recreate web_udc


 пересобираем один после проверки на таблицы!
docker compose rm -f udc_db_init
docker compose up udc_db_init

пересоберем все!
docker compose down
docker compose up -d --force-recreate
docker compose ps -a

---------------------
docker compose config

cd ..

docker build -f docker/WEB_UDC/Dockerfile -t web_udc:latest .

cd docker

docker compose up -d --force-recreate web_udc

docker compose ps -a


---------------------add test File
проверка файлов 
MSYS_NO_PATHCONV=1 docker exec web_udc ls -la /app/import
MSYS_NO_PATHCONV=1 docker exec web_udc ls -la /app/export