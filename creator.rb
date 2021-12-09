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
    @split_span = 10_000
    @mixed_file_amount = 10
    @max_number_of_digits = 10
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
    end_of_file_number = 0
    File.open(unpacked_file_name) do |unpacked_file|
      # テーブル作成用 SQL 生成
      file_no = 0
      col1_title, col2_title = unpacked_file.gets.split

      File.open("#{sprintf("%010d", file_no)}_#{sql_file_name}", mode = "w") do |sql|
        sql.write(<<~"SQL")
        drop table if exists page;
        create table page (
          id                    bigint           auto_increment primary key,
          #{col1_title}         varchar(255)     not null comment '#{col1_title}',
          #{col2_title}         varchar(255)     not null comment '#{col2_title}'
        );
        SQL
      end

      file_no = file_no + 1
      end_of_file_number = end_of_file_number + 1
      while true
        raise "Over File Number" if file_no.to_s.size >= @max_number_of_digits
          File.open("#{sprintf("%0#{@max_number_of_digits}d", file_no)}_#{sql_file_name}", mode = "w") do |sql|
            @split_span.times.each {
              col1, col2 = unpacked_file.gets&.split&.map{|col| col.delete("'").delete("\\")}
              if col1 && col2
                sql.write("INSERT INTO page(#{col1_title}, #{col2_title}) VALUES ('#{col1}', '#{col2}');\n")
              end
            }
        end

        if unpacked_file.eof?
          break
        else
          file_no = file_no + 1
          end_of_file_number = end_of_file_number + 1
        end
      end
    end
    p "#{lang}用SQLの作成完了✅"

    p "#{lang}用SQLのgzファイルを作成する🗜"
    (0..end_of_file_number).each do |file_number|
      result, err, status = Open3.capture3("gzip -9c #{sprintf("%010d", file_number)}_#{sql_file_name} > #{sprintf("%0#{@max_number_of_digits}d", file_number)}_#{sql_file_name}.gz")
      p "ファイル作成で問題が発生しました🗜: #{[result, err, status]}" if !err&.empty?
    end
    p "#{lang}用SQLのgzファイルが作成完了✅"
  end

  # 各言語のSQLファイルは存在している前提で実行する
  def constract_mixed_sql(max_row_size = 250_000, sql_file_name:)
    Dir.chdir(@workspace_dir)
    # ダウンロードする言語のフォルダを作成する
    `mkdir -p resource/mixed`
    Dir.chdir("./resource/mixed")

    # 追記処理をするため、既存のファイルは一度消す
    if File.exist?(sql_file_name)
      p "ファイルが既に存在しているため、一度削除します🗑"
      File.delete(sql_file_name) if File.exist?(sql_file_name)
      File.delete("#{sql_file_name}.gz") if File.exist?("#{sql_file_name}.gz")
      p "削除が完了🗑"
    end

    p "mixed用SQLを用意する📝"
    copy_count = 0
    @languages.each_with_index do |lang, lang_index|
      p "各言語SQLをコピーしてくる"
      if lang_index.zero?
        result, err, status = Open3.capture3("cp #{@workspace_dir}/resource/#{lang}/#{sprintf("%0#{@max_number_of_digits}d", 0)}_#{sql_file_name}.gz #{sprintf("%0#{@max_number_of_digits}d", copy_count)}_#{sql_file_name}.gz")
        p "ファイルコピー結果🗜: #{[result, err, status]}"
        p "ファイルコピー成功✅" if !!err&.empty?
        copy_count = copy_count + 1
      end

      (1..@mixed_file_amount).each do |file_number|
        result, err, status = Open3.capture3("cp #{@workspace_dir}/resource/#{lang}/#{sprintf("%0#{@max_number_of_digits}d", file_number)}_#{sql_file_name}.gz #{sprintf("%0#{@max_number_of_digits}d", copy_count)}_#{sql_file_name}.gz")
        p "ファイルコピー結果🗜: #{[result, err, status]}"
        p "ファイルコピー成功✅" if !!err&.empty?
        copy_count = copy_count + 1
      end

    end

    # データを結合する場合
    # File.open(sql_file_name, mode = "a") do |sql|
    #   @languages.each_with_index do |lang, lang_index|

    #     p "#{lang}言語のファイルセットアップを行います💻"
    #     construct_sql(lang: lang, sql_file_name: sql_file_name)
    #     p "#{lang}言語のファイルセットアップが完了✅"

    #     if lang_index.zero?
    #       File.open("#{@workspace_dir}/resource/#{lang}/#{sprintf("%0#{@max_number_of_digits}d", 0)}_#{sql_file_name}") do |lang_sql|
    #         lang_sql.each_line { |line| sql.write(line) }
    #       end
    #     end

    #     (1..@mixed_file_amount).each do |file_number|
    #       File.open("#{@workspace_dir}/resource/#{lang}/#{sprintf("%0#{@max_number_of_digits}d", file_number)}_#{sql_file_name}") do |lang_sql|
    #         lang_sql.each_line { |line| sql.write(line) }
    #       end
    #     end

    #   end
    # end
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