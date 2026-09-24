В комплекте:
- install_udc_2.cmd — первая сборка, создание контейнеров и инициализация базы.
- start_udc_2_local_Docker&SQL.cmd — повторный локальный запуск.
- start_udc_2_tunnel_loc-public.cmd — туннель для работающего приложения.
- start_udc_2_tunnel_loc-public_all.cmd — локальный запуск, затем туннель.
- Общий udc.ps1 и инструкции.

2_UDC_web/
├── app/
├── docker/
│   ├── compose.yml
│   ├── .env
│   ├── SQL_SEVER_2025/
│   ├── udc_db_init/
│   └── web_udc/
└── script/
    └── deployment/
        ├── udc.ps1
        ├── install_udc_2.cmd
        ├── start_udc_2_local_Docker&SQL.cmd
        ├── start_udc_2_tunnel_loc-public.cmd
        ├── start_udc_2_tunnel_loc-public_all.cmd
        └── инструкции

способы:
- Клонировать репозиторий из GitHub.
- Скопировать папку проекта на другой компьютер или диск.
При этом нужно:
1. Установить и настроить Docker Desktop с Linux containers.
2. Сохранить структуру папок, включая комплект в 2_UDC_web\script\deployment.
3. Создать 2_UDC_web\docker\.env с паролем — из GitHub этот файл не загрузится.
4. Запустить install_udc_2.cmd. Для скачивания образов и зависимостей нужен интернет.
5. Для публичной ссылки дополнительно установить cloudflared.
Важно: копирование файлов не переносит существующую базу из Docker volumes. На новом компьютере будет создана база из SQL-скриптов проекта; для переноса накопленных данных нужен отдельный backup.