require './creator'

p "SQLファイルの生成を開始🏁"
creator = Creator.new(FILE_NAME, LANGUAGES, WORKSPACE_DIR, MAX_NUMBER_OF_DIGITS)

creator.constract_mixed_sql(sql_file_name: SQL_FILE_NAME)

p "全言語を混ぜたmixedSQLファイルの生成が終わったよ👍"