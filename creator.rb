require 'open3'
# 更に再利用される可能性がある場合
# Creator:Fileを1:1にする
#   現状は曖昧。ただ、生成するSQL自体が元データに依存しているのでこのままにしている
#   実施する場合は、生成するSQLもテンプレートとして流し込める形にする
class Creator

  def initialize(file_name, languages, workspace_dir)
    @file_name = file_name #最初に言語を追加する必要あり
    @languages = languages
    @workspace_dir = workspace_dir
  end

  def construct_sql(lang:, sql_file_name:)
    Dir.chdir(@workspace_dir)
    # ダウンロードする言語のフォルダを作成する
    `mkdir -p ./resource/#{lang}`
    Dir.chdir("./resource/#{lang}")

    file_name = "#{lang}#{@file_name}"
    unpacked_file_name = file_name.split(".").slice(0..-2).join
    url = "https://dumps.wikimedia.org/#{lang}wiki/20211101/#{file_name}"
    download(url: url, file_name: file_name)
    unpack(target_file_name: file_name, unpacked_file_name: unpacked_file_name)

    p "#{lang}用SQLを作成する📝"
    File.open(unpacked_file_name) do |unpacked_file|
      col1_title, col2_title = unpacked_file.gets.split

      File.open(sql_file_name, mode = "w") do |sql|
        sql.write(<<~"SQL")
        drop table if exists page;
        create table page (
          id                    bigint           auto_increment primary key,
          #{col1_title}         varchar(255)     not null comment '#{col1_title}',
          #{col2_title}         varchar(255)     not null comment '#{col2_title}'
        );
        SQL

        unpacked_file.each_line do |line|
          col1, col2 = unpacked_file.gets&.split&.map{|col| col.delete("'")}&.map{|col| col.delete("\\")}
          if col1 && col2
            sql.write("INSERT INTO page(#{col1_title}, #{col2_title}) VALUES ('#{col1}', '#{col2}');\n")
          end
        end
      end
    end
    p "#{lang}用SQLの作成完了✅"

    p "#{lang}用SQLのgzファイルを作成する🗜"
    result, err, status = Open3.capture3("gzip -9c #{sql_file_name} > #{sql_file_name}.gz")
    p "ファイル作成結果🗜: #{[result, err, status]}"
    p "#{lang}用SQLのgzファイルが作成完了✅" if !!err&.empty?
  end

  def constract_mixed_sql(max_row_size = 250_000, sql_file_name:)
    Dir.chdir(@workspace_dir)
    # ダウンロードする言語のフォルダを作成する
    `mkdir -p resource/mixed`
    Dir.chdir("./resource/mixed")

    # 追記処理をするため、既存のファイルは一度消す
    if File.exist?(sql_file_name)
      p "ファイルが既に存在しているため、一度削除します🗑"
      File.delete(sql_file_name)
      File.delete("#{sql_file_name}.gz")
      p "削除が完了🗑"
    end

    p "mixed用SQLを作成する📝"
    @languages.each_with_index do |lang, lang_index|
      p "#{lang}言語のファイルセットアップを行います💻"
      construct_sql(lang: lang, sql_file_name: sql_file_name)
      p "#{lang}言語のファイルセットアップが完了✅"

      file_name = "#{lang}#{@file_name}"
      unpacked_file_name = file_name.split(".").slice(0..-2).join
      File.open("#{@workspace_dir}/resource/#{lang}/#{unpacked_file_name}") do |unpacked_file|
        col1_title, col2_title = unpacked_file.gets.split

        File.open(sql_file_name, mode = "a") do |sql|
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

          unpacked_file.each_line.with_index(1) do |line, row_number|
            break if row_number > max_row_size
            col1, col2 = unpacked_file.gets&.split&.map{|col| col.delete("'")}&.map{|col| col.delete("\\")}
            if col1 && col2
              sql.write("INSERT INTO page(#{col1_title}, #{col2_title}) VALUES ('#{col1}', '#{col2}');\n")
            end
          end
        end
      end
    end

    p "mixed用SQLを作成完了✅"

    p "SQLのgzファイルを作成する🗜"
    result, err, status = Open3.capture3("gzip -9c #{sql_file_name} > #{sql_file_name}.gz")
    p "ファイル作成結果🗜: #{[result, err, status]}"
    p "SQLのgzファイルが作成完了✅" if !!err&.empty?
  end

  private

  def download(file_destination_path = "./", force = false, url:, file_name:)
    p "#{file_name}をDLする⏬"

    if File.file?("#{file_destination_path}#{file_name}") && !force
      p "#{file_name}は既にDLされているためスキップ⏩"
    else
      result, err, status = Open3.capture3("aria2c -x5 -d #{file_destination_path} #{url}")
      p "DL結果🗳: #{[result, err, status]}"
    end
    !!err&.empty?
  end

  def unpack(file_destination_path = "./", force = false, target_file_name:, unpacked_file_name:)
    p "#{target_file_name}を解凍する🔓"

    extension = if target_file_name.split(".").size > 1
                  target_file_name.split(".")[-1]
                else
                  nil
                end
    unless extension
      p "拡張子がファイルにセットされていません"
      return false
    end

    if File.file?("#{file_destination_path}#{unpacked_file_name}") && !force
      p "#{target_file_name}は既に解凍されているためスキップ⏩"
    else
      if extension == "gz"
        stdout, stderr, status = Open3.capture3("gzip -dc #{file_destination_path}#{target_file_name} > #{unpacked_file_name}")
        p "ファイル解凍結果: #{[stdout, stderr, status]}"
      end
    end
  end
end