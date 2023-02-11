resource "aws_ecr_repository" "container_repo" {
  count = var.env_name == "mgmt" ? 1 : 0
  name  = "mission-api"
}

resource "aws_ecr_repository" "helm_repo" {
  count = var.env_name == "mgmt" ? 1 : 0
  name  = "mission-api-helm"
}