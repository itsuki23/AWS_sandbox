# Rule
- リソース毎に大枠で分けてapplyする
- moduleは参照データ(idなど)、IAM、SecurytyGroup使用
- ssmパラメータストアはRDSのユーザー名、パスワードのみ使用
- 奇数はprivate、偶数はpublic

# module参照リスト
module.***.vpc_id
module.***.public_subnet_1a
module.***.public_subnet_1c
module.***.private_subnet_1a
module.***.private_subnet_1c
module.***.ec2_bastion
module.***.ec2_nat
module.***.ec2_web_1
module.***.ec2_web_2
module.***.ec2_app_1

# Command
```sh
$ terraform fmt -recursive (-check)
$ terraform validate
```