data "aws_secretsmanager_secret_version" "dev_kubeconfig" {
  secret_id = "argocd/clusters/kubeconfigs/argocd-demo-dev"
}

data "aws_secretsmanager_secret_version" "prod_kubeconfig" {
  secret_id = "argocd/clusters/kubeconfigs/argocd-demo-prod"
}

data "aws_eks_cluster" "dev" {
  name = "argocd-demo-dev"
}

data "aws_eks_cluster" "prod" {
  name = "argocd-demo-prod"
}
