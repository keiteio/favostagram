favostagram
---------------------------------------
#目的
twitter/instagram/pixiv/tumblrでfavoったツイートの画像を一括で閲覧・ダウンロードする


#使い方
###事前準備
[TwitterDevelopers](https://apps.twitter.com/)でConsumer keyとConsumer secretを取得しておく

###準備
1 ソースコードをclone

```
$ git clone https://github.com/keiteio/favostagram
$ cd favostagram
$ bundle install
```

2 app.yml.sampleをapp.ymlにrenameして、
&nbsp;&nbsp;以下を取得したConsumer keyとConsumer secretに書き換える

```
api-key: <YOUR API KEY>
api-secret: <YOUR API SECRET>
```

3 sinatra起動

```
$ rackup
```

###画面

####一覧表示
`http://local:9292`
※スクロールで５件ずつ追加読み込み
####一括ダウンロード
`http://local:9292/download`


#注意
まだ開発中なので以下のようなバグがあります。

+ 時々、同じ画像を表示してしまう
+ API問い合わせが最適化されていないので、TooManyRequestsでよく落ちる


#参考
以下のサイトを参考に作成しています。
[Herokuを利用したナントカstagramの作り方](http://rewish.jp/blog/dev/heroku_nantokastagram)