FROM mysql:5.7

COPY ./resource/mixed/*create-sample.sql.gz /docker-entrypoint-initdb.d/
COPY ./docker/db/my.cnf /etc/mysql/conf.d/