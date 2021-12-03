#!/bin/sh
(
  cd resource/en/
  gzip -dc enwiki-20211101-page.sql.gz > enwiki.sql
  sed '53,5800d' enwiki.sql > enwiki-slim.sql
  gzip -9 -c enwiki-slim.sql > enwiki-slim.sql.gz
  rm enwiki-20211101-page.sql.gz
  rm enwiki.sql
)