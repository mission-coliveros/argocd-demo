locals {
  stack_env_name    = "${var.stack_name}-${var.env_name}"
  cluster_name      = local.stack_env_name
  state_bucket_path = local.stack_env_name
}