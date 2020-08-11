# コマンド例
- 基本
```sh
$ terraform init
$ terraform plan
$ terraform apply
```

- 成形、確認、リファクタリング
```sh
$ terraform fmt
$ terraform validate
$ terraform lint
```

- 構成画像作成
```sh
$ dot -Tpng <(terraform graph) -o dependency.png
```

- 出力
```sh
$ terraform output
```