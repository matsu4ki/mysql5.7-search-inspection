require './creator'

p "SQLファイルの生成を開始🏁"
creator = Creator.new(FILE_NAME, LANGUAGES, WORKSPACE_DIR, MAX_NUMBER_OF_DIGITS)

# 削除
[*LANGUAGES, 'mixed'].each do |folder_name|
  result, err, status = Open3.capture3("find #{WORKSPACE_DIR}/resource/#{folder_name}/ -name '*#{SQL_FILE_NAME}*' -print | xargs rm")
  p "#{[result, err, status]}"
end

# 各言語を個別で生成
creator.construct_sql(SPLIT_SPAN, lang: :ja, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(SPLIT_SPAN, lang: :en, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(SPLIT_SPAN, lang: :vi, sql_file_name: SQL_FILE_NAME)
creator.construct_sql(SPLIT_SPAN, lang: :th, sql_file_name: SQL_FILE_NAME)

p "各種言語のSQLファイル生成が終わったよ👍"