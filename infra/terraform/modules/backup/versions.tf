# This module spans two regions: the default `aws` provider (us-east-1) holds
# the source vault, plan, selection and the service role; `aws.usw2` holds the
# us-west-2 destination vault that receives the cross-region copy.
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.0"
      configuration_aliases = [aws.usw2]
    }
  }
}
