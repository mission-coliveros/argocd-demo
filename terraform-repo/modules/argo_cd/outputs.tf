output "argocd_secret" {
  value = "https://${var.aws_region}.console.aws.amazon.com/secretsmanager/secret?name=${urlencode(aws_secretsmanager_secret.argocd_admin_password.name)}&region=${var.aws_region}"
}

output "argocd_url" {
  value = data.kubernetes_service_v1.argocd_server.status[0].load_balancer[0]["ingress"][0]["hostname"]
}