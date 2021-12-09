require './creator'

p "SQLファイルの生成を開始🏁"
creator = Creator.new(FILE_NAME, LANGUAGES, WORKSPACE_DIR)

creator.constract_mixed_sql(max_row_size = MAX_ROW_SIZE, sql_file_name: SQL_FILE_NAME)

p "全言語を混ぜたmixedSQLファイルの生成が終わったよ👍"