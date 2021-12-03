#!/bin/sh
# download
aria2c -x5 -d ./resource/ja/ https://dumps.wikimedia.org/jawiki/20211101/jawiki-20211101-page.sql.gz
aria2c -x5 -d ./resource/en/ https://dumps.wikimedia.org/enwiki/20211101/enwiki-20211101-page.sql.gz
aria2c -x5 -d ./resource/vi/ https://dumps.wikimedia.org/viwiki/20211101/viwiki-20211101-page.sql.gz
aria2c -x5 -d ./resource/th/ https://dumps.wikimedia.org/thwiki/20211101/thwiki-20211101-page.sql.gz

./cut-en-wiki.sh