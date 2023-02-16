output "argocd_secret" {
  value = var.deploy_argo_cd ? module.argo_cd[0].argocd_secret : null
}

output "argocd_url" {
  value = var.deploy_argo_cd ? "https://${module.argo_cd[0].argocd_url}" : null
}