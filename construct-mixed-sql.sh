#!/bin/sh
(
  cd resource/
  gzip -dc en/enwiki-20211101-page.sql.gz > mixed/enwiki.sql
  gzip -dc ja/jawiki-20211101-page.sql.gz > mixed/jawiki.sql
  gzip -dc th/thwiki-20211101-page.sql.gz > mixed/thwiki.sql
  gzip -dc vi/viwiki-20211101-page.sql.gz > mixed/viwiki.sql

  cd mixed
  rm -f mixed-insert.sql

  sed -n 1,351p enwiki.sql >> mixed-insert.sql
  sed -n 352,651p jawiki.sql >> mixed-insert.sql
  sed -n 652,951p thwiki.sql >> mixed-insert.sql
  sed -n 952,1251p viwiki.sql >> mixed-insert.sql
  gzip -9 -c mixed-insert.sql > mixed-insert.sql.gz

  rm -f *wiki.sql
)