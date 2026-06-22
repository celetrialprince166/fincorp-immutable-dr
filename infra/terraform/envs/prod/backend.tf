# Remote state in S3 with native lockfile locking (no DynamoDB). Create the bucket
# once before `terraform init`, then fill in the name. State lives in us-east-1.
terraform {
  backend "s3" {
    bucket       = "REPLACE-fincorp-tfstate-<account-id>-use1"
    key          = "fincorp/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
