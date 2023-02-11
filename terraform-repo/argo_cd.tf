module "argo_cd" {
  count  = var.deploy_argo_cd ? 1 : 0
  source = "./modules/argo_cd"

  env_name              = var.env_name
  argocd_version        = var.argocd_version
  deploy_argo_manifests = var.deploy_argo_manifests
  gitops_repo_password  = data.aws_secretsmanager_secret_version.gitops_repo_token.secret_string
  gitops_repo_username  = "admin"
  image_repo_name       = "argocd-demo-container-images"
  ecr_updater_repos     = [aws_ecr_repository.helm_repo[0].arn]
}
