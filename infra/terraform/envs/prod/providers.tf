# Default provider = primary region (us-east-1). Aliased provider = DR region
# (us-west-2). AWS Backup cross-region copy and the DR restore reference aws.usw2.
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project   = "fincorp"
      Env       = "prod"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias  = "usw2"
  region = var.dr_region

  default_tags {
    tags = {
      Project   = "fincorp"
      Env       = "prod"
      ManagedBy = "terraform"
    }
  }
}
