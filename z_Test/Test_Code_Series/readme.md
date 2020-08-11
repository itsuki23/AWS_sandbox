# Workflow
```
<firstable>
  - init
  - network
  - baastion
  - module set

<server>

<lob>
```

# 1. Preparation
## init
- 自身のipアドレスをssmへ登録
- tfstateファイル用のs3を作成
- コンソールで作成したものをもとにimport、tf化、リファレンスを参考に補正

## network
- vpc, subnetを作成

## bastion
- 踏み台、デバッグ、コントロールノードとして。
## modules
- コンポーネントとしてカプセル化
```
- init　: provider, credential, s3バケットを定義
- var   : 変数を定義
- params: tagでフィルターをかけた値をアウトプット定義
- sg    : security group
- iam   : iam
```

