FROM mysql:5.7

COPY ./resource/vi/*.sql.gz /docker-entrypoint-initdb.d/
COPY ./docker/db/my.cnf /etc/mysql/conf.d/