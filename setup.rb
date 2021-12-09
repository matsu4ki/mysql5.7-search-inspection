require './creator'

SQL_FILE_NAME = "create-sample.sql"
LANGUAGES = [:ja, :en, :vi, :th]
WORKSPACE_DIR = Dir.pwd.freeze
MAX_ROW_SIZE = 250_000
FILE_NAME = "wiki-20211101-all-titles.gz"

# load('create-lang-sql.rb')
load('create-mixed-sql.rb')
