FROM mysql:5.7

COPY ./resource/ja/*.sql.gz /docker-entrypoint-initdb.d/