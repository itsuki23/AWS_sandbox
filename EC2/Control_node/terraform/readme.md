# Terraform

```s
# Terraform/Dockerfile

FROM python:3.6

ARG pip_installer="https://bootstrap.pypa.io/get-pip.py"
ARG awscli_version="1.16.168"

# install aws-cli
RUN pip install awscli==${awscli_version}

# install sam
# RUN pip install --user --upgrade aws-sam-cli
# ENV PATH $PATH:/root/.local/bin

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip

# install terraform.
# https://azukipochette.hatenablog.com/entry/2018/06/24/004354
RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
    unzip ./terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/

# create workspace.
COPY ./src /root/src

# initialize
COPY /home/ec2-user/.aws /root/.aws

WORKDIR /root/src
```

# Reference
https://qiita.com/reflet/items/de57ae767c8f368372ba
https://github.com/yuta-ushijima/terraform_handson_on_docker