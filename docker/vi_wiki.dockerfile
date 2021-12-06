FROM mysql:5.7

COPY ./resource/vi/*.sql.gz /docker-entrypoint-initdb.d/