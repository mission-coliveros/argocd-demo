provider "aws" {
  region = local.region
  allowed_account_ids = [843238382912]

  default_tags {
    tags = {
      owner             = "mission-coliveros"
      project           = "argocd-demo-2023"
      terraform-managed = "true"
    }
  }
}

provider "aws" {
  alias  = "replica"
  allowed_account_ids = [843238382912]
  region = local.backup_region
}