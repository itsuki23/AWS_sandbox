#! /bin/sh

# define bucket name
bucket_name=myk-tfstate-bucket    # read -p "s3 bucket name:" bucket_name
profile_name=itsuki               # read -p "aws profile name:" profile_name

echo "s3 bucket name for tfstate file: $bucket_name"
echo "select credential profile: $profile_name"

# create s3 bucket
aws --profile $profile_name s3api create-bucket --bucket $bucket_name \
--create-bucket-configuration LocationConstraint=ap-northeast-1

# versioning setting
aws --profile $profile_name s3api put-bucket-versioning --bucket $bucket_name \
--versioning-configuration Status=Enabled 

# enctypt
aws --profile $profile_name s3api put-bucket-encryption --bucket $bucket_name \
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
aws --profile $profile_name s3api put-public-access-block --bucket $bucket_name \
--public-access-block-configuration '{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}'
