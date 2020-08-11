# Init
## IP Adress登録
```
$ aws --profile <credential profile> ssm put-parameter --name '/myk/ip/home' --value '<home ip>' --type String
$ aws --profile <credential profile> ssm put-parameter --name '/myk/ip/office' --value '<office ip>' --type String
```

## S3 <tfstateの管理準備>

- ファイル内で、バケット名、クレデンシャルを指定して実行
```sh
$ . s3_private_bucket.sh
```

## マネジメントコンソールで作成したインフラ構成をコード化
```
$ terraform import <awsリソース>.<任意のID> <importに必要なidやあarnなど>
```
上記のterraform importを使って出力されたリソース情報をリファレンスを参考に各ファイルに記述