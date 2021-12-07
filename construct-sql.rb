require 'open3'

DEFAULT_DIR = Dir.pwd.freeze
SQL_FILE_NAME = "create-sample.sql"

["ja","en","vi","th"].each_with_index do |lang, index|
  # DL
  p "#{lang}用データのDLする⏬"
  Dir.chdir(DEFAULT_DIR)
  Dir.chdir("./resource/#{lang}")

  if File.file?("./#{lang}wiki-20211101-all-titles.gz")
    p "#{lang}用データは既にDLされているためスキップ⏩"
  else
    result, err, status = Open3.capture3("aria2c -x5 -d ./ https://dumps.wikimedia.org/#{lang}wiki/20211101/#{lang}wiki-20211101-all-titles.gz")
    p "DL結果🗳: #{[result, err, status]}"
  end

  # ファイル生成
  p "#{lang}用データを解凍する🔓"
  stdout, stderr, status = Open3.capture3("gzip -dc #{lang}wiki-20211101-all-titles.gz > titles.txt")
  p "ファイル解凍結果: #{[stdout, stderr, status]}"

  p "#{lang}用SQLを作成する📝"
  File.open("titles.txt") do |titles|
    col1_title, col2_title = titles.gets.split

    File.open(SQL_FILE_NAME, mode = "w") do |sql|
      sql.write(<<~"SQL")
      drop table if exists page;
      create table page (
        id                    bigint           auto_increment primary key,
        #{col1_title}         varchar(255)     not null comment '#{col1_title}',
        #{col2_title}         varchar(255)     not null comment '#{col2_title}'
      );
      SQL

      titles.each_line do |line|
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
