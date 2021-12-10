require './creator'

SQL_FILE_NAME = "create-sample.sql"
LANGUAGES = [:ja, :en, :vi, :th]
WORKSPACE_DIR = Dir.pwd.freeze
SPLIT_SPAN = 10_000
MAX_NUMBER_OF_DIGITS = 3
FILE_NAME = "wiki-20211101-all-titles.gz"
PARTITION_COL_RANGE = (0..1000)

load('create-lang-sql.rb')
load('create-mixed-sql.rb')