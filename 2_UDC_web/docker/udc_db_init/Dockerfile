# Author: R.Lisovenko
# Date: 22.09.2026
# Description:
# Initialization/verification image for the Converter_UDC database.

FROM mssql_2025_dev:latest

ENV DATA=/data
ENV SCR_DB_INIT=/scr_db_init

USER root

RUN mkdir -p ${DATA} ${SCR_DB_INIT}

COPY init_database.sh ${SCR_DB_INIT}/init_database.sh
COPY init_database.sql ${SCR_DB_INIT}/init_database.sql

RUN chmod +x ${SCR_DB_INIT}/init_database.sh

WORKDIR ${SCR_DB_INIT}

USER mssql

ENTRYPOINT ["./init_database.sh"]
