#data "terraform_remote_state" "dev" {
#  count  = var.deploy_argo_cd ? 1 : 0
#  backend = "s3"
#  config = {
#    bucket = var.state_bucket_name
#    key    = "dev/terraform.tfstate"
#    region = "us-east-1"
#  }
#}

#data "terraform_remote_state" "prod" {
#  count  = var.deploy_argo_cd ? 1 : 0
#  backend = "s3"
#  config = {
#    bucket = var.state_bucket_name
#    key    = "prod/terraform.tfstate"
#    region = "us-east-1"
#  }
#}

data "aws_iam_role" "mission_admin" {
  name = "MissionAdministrator"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_secretsmanager_secret" "gitops_repo_token" {
  name = "argocd/repositories/argocd-demo/token"
}

data "aws_secretsmanager_secret_version" "gitops_repo_token" {
  secret_id = data.aws_secretsmanager_secret.gitops_repo_token.id
}