#resource "aws_iam_policy" "argocd_vault_plugin_nodegroup" {
#  name = "${var.env_name}-argocd-vault-plugin-nodegroup"
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Sid = "ArgoCDSecrets"
#        Action = [
#          "secretsmanager:DescribeSecret",
#          "secretsmanager:GetResourcePolicy",
#          "secretsmanager:GetSecretValue",
#          "secretsmanager:ListSecretVersionIds",
#          "secretsmanager:ListSecrets"
#        ]
#        Effect = "Allow"
#        Resource = [
#          data.aws_secretsmanager_secret.gitops_repo_token.arn,
#        ]
#      }
#    ]
#  })
#}

module "argo_cd" {
  count  = var.deploy_argo_cd ? 1 : 0
  source = "modules/argo_cd"

  env_name              = var.env_name
  argocd_version        = var.argocd_version
  deploy_argo_manifests = var.deploy_argo_manifests
  gitops_repo_password  = data.aws_secretsmanager_secret_version.gitops_repo_token.secret_string
  gitops_repo_username  = "admin"
  image_repo_name       = "argocd-demo-container-images"
  ecr_updater_repos     = [aws_ecr_repository.helm_repo[0].arn]
}
