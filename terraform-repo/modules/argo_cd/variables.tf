variable "stack_name" {
  default     = "argocd-demo"
  type        = string
  description = "The name of environment"
}

variable "env_name" {
  type        = string
  description = "The name of environment"
}

variable "aws_region" {
  type        = string
  description = "The AWS Region to deploy resources"
  default     = "us-west-2"
}

variable "argocd_version" {
  type        = string
  description = "Helm chart version for ArgoCD"
}

variable "argocd_service_type" {
  type        = string
  default     = "LoadBalancer"
  description = "Type of service to configure for ArgoCD server manifest"
}

variable "deploy_argo_manifests" {
  default     = false
  type        = bool
  description = "Whether or not to deploy IWH workloads to EKS"
}

variable "argocd_ecr_updater_chart_version" {
  type        = string
  default     = "0.3.8"
  description = "Helm chart version for ArgoCD ECR updater"
}

variable "ecr_registry" {
  type        = string
  default     = "843238382912.dkr.ecr.us-west-2.amazonaws.com"
  description = "ECR registry that hosts Helm charts for EKS workloads"
}

variable "ecr_updater_repos" {
  type        = list(string)
  default     = []
  description = "Repos to be included in ECR updater role/policy"
}

variable "image_repo_name" {
  type = string
}

variable "gitops_repo_username" {
  type        = string
  sensitive   = true
  description = "Authentication for GitOps repo in GitHub"
}

variable "gitops_repo_password" {
  type        = string
  sensitive   = true
  description = "Authentication for GitOps repo in GitHub"
}

#variable "clusters" {
#  type = set(
#    object(
#      {
#        name   = string
#        server = string
#        config = string
#      }
#    )
#  )
#}