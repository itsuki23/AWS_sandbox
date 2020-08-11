# Control Node
- 実行、踏み台、デバッグ用


# Setup
## - aws config
```sh
$ mkdir /home/ec2-user/.aws
$ cd /home/ec2-user/.aws
$ vi config
------------------------------
[default]
output=json
region=ap-northeast-1

[profile IAMユーザー名]
region=ap-northeast-1
------------------------------

$ vi credentials
------------------------------
[default]
aws_access_key_id = ...
aws_secret_access_key = ...

[IAMユーザー名]
aws_access_key_id=...
aws_secret_access_key=...
------------------------------

$ which aws
$ aws --version
$ aws sts get-caller-identity
$ aws s3 ls
```

## - docker
```sh
$ sudo yum update -y
$ sudo amazon-linux-extras | grep docker
$ sudo amazon-linux-extras install -y docker

$ docker -v
$ sudo systemctl start docker
$ sudo systemctl status docker
$ sudo systemctl enable docker
$ sudo systemctl is-enabled docker

$ sudo gpasswd -a $USR docker
$ sudo systemctl restart docker
$ sudo systemcltl status docker
$ getent group docker

# version: https://github.com/docker/compose/releases
$ sudo curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version 
```

## - IAM
```sh
# case by case
・S3
・SSM
・ECR
・CloudFormation
```

## - SSH key
```sh
# local
$ scp -i ~/.ssh/miyake-key.pem ~/.ssh/miyake-key.pem ec2-user@<EC2_ip>:/home/ec2-user/.ssh
$ chmod 600 ~/.ssh/miyake-key.pem
```
- ssmで対応するなら要らない


## - Command
```S
yum install -y iproute net-tools; \
curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64; \
chmod +x /usr/loca/bin/jq; \
```
- 但し非推奨: https://server.etutsplus.com/centos-7-net-tools-vs-iproute2/

## - Terraform
- 必要であれば./terraform/Dockerfileから実行




