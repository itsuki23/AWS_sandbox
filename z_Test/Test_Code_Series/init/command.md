# コマンド例
- 基本
```sh
$ terraform init
$ terraform plan
$ terraform apply

# default以外のcredentials使用したときにエラーが出たら...
$ AWS_PROFILE=<profile> terraform init
$ AWS_PROFILE=<profile> terraform plan
$ AWS_PROFILE=<profile> terraform apply
```

- 成形、確認、リファクタリング
```sh
$ terraform fmt
$ terraform validate
$ tflint
```

- 構成画像作成
```sh
$ dot -Tpng <(terraform graph) -o dependency.png
```

- 出力
```sh
$ terraform output
```