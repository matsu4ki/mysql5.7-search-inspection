require './creator'

p "SQLファイルの生成を開始🏁"
creator = Creator.new(FILE_NAME, LANGUAGES, WORKSPACE_DIR)

# 削除
`find #{WORKSPACE_DIR}/resource/(#{LANGUAGES.join("|")})/ -name "*#{SQL_FILE_NAME}*" -print | xargs rm`
# 各言語を個別で生成
creator.construct_sql(lang: :ja, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(lang: :en, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(lang: :th, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(lang: :vi, sql_file_name: SQL_FILE_NAME)

p "各種言語のSQLファイル生成が終わったよ👍"