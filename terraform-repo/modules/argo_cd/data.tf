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

data "kubernetes_secret_v1" "argocd_admin_password" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = helm_release.argocd.namespace
  }
}

data "kubernetes_service_v1" "argocd_server" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
}