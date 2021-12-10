# MySQL5.7における検索の性能検証

mySQL5.7における、検索の検証を行う。
データ容量、速度の観点から判断する。
3つの実装方法で検討する。

- Like検索
- Like検索 + パーティショニング
- 全文検索

それぞれについて、検索用のテーブルを作成し
数回ワード検索を行い、判断する。

## 注意事項

検索対象はVARCHAR型を想定していたが、wikipediaのデータはVARBINARY型だった。
VARBINARYとVARCHARのダミーデータを用意して比較してみたところ、VARBINARYの方が速度的に少し速い以外の差が見られなかったため、
本検証はVARBINARYのカラムで実施する。

## 計測方法

「Like」「Like + Partition」「Full Text Search」実装を行い、検索した際の

- 総データ容量
  - `docker ps -s`のSIZE
- 検索速度
  - SQL実行 - 返却まで

を計測する。
SIZEは、virtualのものと表示されているサイズの合計値で判断する
https://github.com/docker/docker.github.io/issues/1520#issuecomment-305179362

## データの取得方法

- https://dumps.wikimedia.org/jawiki/20211101/
- https://dumps.wikimedia.org/enwiki/20211101/
- https://dumps.wikimedia.org/viwiki/20211101/
- https://dumps.wikimedia.org/thwiki/20211101/

から、タイトル情報のダンプデータを取得する。
英語タイトルの量が多すぎるため、sedである程度量をカットしている。

wikiデータのテーブル説明は
https://www.mediawiki.org/wiki/Manual:Page_table/ja
に記載あり。

ライセンス等に関してはこちらを参照
https://ja.wikipedia.org/wiki/Wikipedia:%E3%82%A6%E3%82%A3%E3%82%AD%E3%83%9A%E3%83%87%E3%82%A3%E3%82%A2%E3%82%92%E4%BA%8C%E6%AC%A1%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B