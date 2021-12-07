def download_wiki_title(lang:)
  # ダウンロードする言語のフォルダを作成する
  `mkdir resource/#{lang}`

  if File.file?("./#{lang}wiki-20211101-all-titles.gz")
    p "#{lang}用データは既にDLされているためスキップ⏩"
  else
    result, err, status = Open3.capture3("aria2c -x5 -d ./ https://dumps.wikimedia.org/#{lang}wiki/20211101/#{lang}wiki-20211101-all-titles.gz")
    p "DL結果🗳: #{[result, err, status]}"
  end
  !!err&.empty?
end