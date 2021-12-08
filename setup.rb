require './creator'

SQL_FILE_NAME = "create-sample.sql"
LANGUAGES = [:ja, :en, :vi, :th]
WORKSPACE_DIR = Dir.pwd.freeze
MAX_ROW_SIZE = 250_000
FILE_NAME = "wiki-20211101-all-titles.gz"

p "SQLファイルの生成を開始🏁"
creator = Creator.new(FILE_NAME, LANGUAGES, WORKSPACE_DIR)
creator.constract_mixed_sql(max_row_size = MAX_ROW_SIZE, sql_file_name: SQL_FILE_NAME)

p "各種言語および、全言語を混ぜたSQLファイルの生成が終わったよ👍"