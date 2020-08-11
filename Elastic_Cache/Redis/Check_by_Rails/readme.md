# Elastic Cache (Redis)
### Elastic Cache設定
```
security_group: ingress 6379 EC2-SG
```

### EC2設定
```
$ sudo amazon-linux-extras install redis4.0
$ redis-cli -c -h <redis_end_point> -p 6379
  > set <key> "<value>"
  > get <key>
```

### Redisの動作確認
まだうまくいっていない
```
# docker, docker-composeをインストール後
$ docker-compose up

# 詳細はDockerfile参照
```