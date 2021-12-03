FROM mysql:5.7

COPY ./resource/en/*.sql.gz /docker-entrypoint-initdb.d/