# Remote state in S3 with native lockfile locking (no DynamoDB). The bucket is a
# versioned, AES256-encrypted, public-access-blocked bucket bootstrapped once via
# the AWS CLI. State lives in us-east-1.
terraform {
  backend "s3" {
    bucket       = "fincorp-tfstate-648637468459-use1"
    key          = "fincorp/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
