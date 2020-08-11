#! /bin/sh

# define bucket name
bucket_name=myk-tfstate    # read -p "s3 bucket name:" bucket_name



# create s3 bucket
aws s3api create-bucket --bucket $bucket_name \
--create-bucket-configuration LocationConstraint=ap-northeast-1

# versioning setting
aws s3api put-bucket-versioning --bucket $bucket_name \
--versioning-configuration Status=Enabled

# enctypt
aws s3api put-bucket-encryption --bucket $bucket_name \
--server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

# block public access
aws s3api put-public-access-block --bucket $bucket_name \
--public-access-block-configuration '{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}'
