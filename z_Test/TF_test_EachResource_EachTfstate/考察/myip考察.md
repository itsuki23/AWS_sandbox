# My_IP考察
- その１
```sh
# Define
provider "http"            { version = "~> 1.1"                     }
data     "http" "ifconfig" { url     = "http://ipv4.icanhazip.com/" }
variable "allowed_cidr"    { default = null                         }

locals {
  current-ip = chomp(data.http.ifconfig.body)
  my_cidr    = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr
}



# Use
local.my_cidr
```

- その２
```sh
<自宅と会社の2つを登録しておきたい場合など>
 ssm parameter storeに登録して使用

# put
$ curl globalip.me
$ aws ssm put-parameter --name '/ip/name/home' --value '.../32' --type String
$ aws ssm put-parameter --name '/ip/name/work' --value '.../32' --type String



# get
data "aws_ssm_parameter" "home_ip" { name  = "/ip/name/home" }
data "aws_ssm_parameter" "work_ip" { name  = "/ip/name/home" }

# use
data.aws_ssm_parameter.home_ip.value
data.aws_ssm_parameter.work_ip.value
```
