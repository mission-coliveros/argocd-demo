# ------------------------------------------------------- Common -------------------------------------------------------

variable "account_id" {
  default = "843238382912"
}

variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy resources"
}

variable "stack_name" {
  default     = "argocd-demo"
  type        = string
  description = "The name of environment"
}

variable "env_name" {
  type        = string
  description = "The name of environment"
}

variable "availability_zones" {
  default     = ["us-west-2a", "us-west-2b"]
  type        = list(string)
  description = "The AWS AZ to deploy EKS"
}

variable "state_bucket_name" {
  default = "argo_cd_demo"
}

variable "terraform_role_arn" {
  default = "arn:aws:iam::843238382912:role/MissionAdministrator"
}

# -------------------------------------------------------- VPC --------------------------------------------------------

variable "vpc_subnet_prefix" {
  type        = string
  description = "The VPC Subnet CIDR"
}

# -------------------------------------------------------- EKS --------------------------------------------------------

variable "k8s_version" {
  default     = "1.24"
  type        = string
  description = "Required K8s version"
}

# -------------------------------------------------------- Argo --------------------------------------------------------

variable "deploy_argo_cd" {
  default = false
}

variable "argocd_version" {
  default = "5.18.1"
}

variable "argocd_target_clusters" {
  type    = set(string)
  default = []
}

variable "deploy_argo_manifests" {
  default = false
}