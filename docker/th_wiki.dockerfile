FROM mysql:5.7

COPY ./resource/th/*.sql.gz /docker-entrypoint-initdb.d/
