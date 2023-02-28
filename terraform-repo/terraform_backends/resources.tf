locals {
  stack_name    = "argocd-demo"
  region        = "us-west-2"
  backup_region = "us-east-1"
  envs = ["dev", "prod", "mgmt"]
}

module "s3_backend" {
  count = length(local.envs)
  source                  = "nozaq/remote-state-s3-backend/aws"
  version                 = "1.4.0"
  enable_replication      = false
  override_s3_bucket_name = true
  s3_bucket_name         = "mission-${local.stack_name}-${local.envs[count.index]}"
  dynamodb_table_name = "mission-${local.stack_name}-${local.envs[count.index]}"
  kms_key_alias = "mission-${local.stack_name}-${local.envs[count.index]}"
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}
