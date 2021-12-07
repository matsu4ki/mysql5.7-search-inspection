require 'open3'

DEFAULT_DIR = Dir.pwd.freeze
SQL_FILE_NAME = "create-sample.sql"
# 各言語から取得する最大データ数
MAX_ROW_SIZE = 250000

# ディレクトリ作成
`mkdir -p resource/mixed`

# 追記処理をするため、既存のファイルは一度消す
if File.exist?("#{DEFAULT_DIR}/resource/mixed/#{SQL_FILE_NAME}")
  p "ファイルが既に存在しているため、一度削除します🗑"
  File.delete("#{DEFAULT_DIR}/resource/mixed/#{SQL_FILE_NAME}")
  File.delete("#{DEFAULT_DIR}/resource/mixed/#{SQL_FILE_NAME}.gz")
  p "削除完了🗑"
end

["ja","en","vi","th"].each_with_index do |lang, lang_index|
  # DL
  p "#{lang}用データのDLする⏬"
  Dir.chdir(DEFAULT_DIR)
  Dir.chdir("./resource/#{lang}")

  download_wiki_title(lang: lang)

  # ファイル生成
  if File.exist?("#{lang}wiki-20211101-all-titles.gz")
    p "#{lang}用データが既に存在しているためスキップ⏩"
  else
    p "#{lang}用データを解凍する🔓"
    stdout, stderr, status = Open3.capture3("gzip -dc #{lang}wiki-20211101-all-titles.gz > titles.txt")
    p "ファイル解凍結果: #{[stdout, stderr, status]}"
  end

  # 書き込み前に位置をリセット
  Dir.chdir(DEFAULT_DIR)
  Dir.chdir("./resource/mixed")

  p "#{lang}用SQLを作成する📝"
  File.open("#{DEFAULT_DIR}/resource/#{lang}/titles.txt") do |titles|
    col1_title, col2_title = titles.gets.split

    File.open(SQL_FILE_NAME, mode = "a") do |sql|
      if lang_index.zero?
        sql.write(<<~"SQL")
        drop table if exists page;
        create table page (
          id                    bigint           auto_increment primary key,
          #{col1_title}         varchar(255)     not null comment '#{col1_title}',
          #{col2_title}         varchar(255)     not null comment '#{col2_title}'
        );
        SQL
      end

      titles.each_line.with_index(1) do |line, row_number|
        break if row_number > MAX_ROW_SIZE
        col1, col2 = titles.gets&.split&.map{|col| col.delete("'")}&.map{|col| col.delete("\\")}
        if col1 && col2
          sql.write("INSERT INTO page(#{col1_title}, #{col2_title}) VALUES ('#{col1}', '#{col2}');\n")
        end
      end
    end
  end

  p "#{lang}用SQLのgzファイルを作成する🗜"
  stdout, stderr, status = Open3.capture3("gzip -9c #{SQL_FILE_NAME} > #{SQL_FILE_NAME}.gz")
  p "ファイル作成結果🗜: #{[stdout, stderr, status]}\n"
end

p "SQL生成スクリプトが終わったよ👍"
