resource "aws_ecr_repository" "container_repo" {
  count = var.env_name == "mgmt" ? 1 : 0
  name  = "${var.stack_name}-container-images"
}

resource "aws_ecr_repository" "helm_repo" {
  count = var.env_name == "mgmt" ? 1 : 0
  name  = "${var.stack_name}-helm-charts"
}