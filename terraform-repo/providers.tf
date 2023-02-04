provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.account_id]
  profile = "mission-internal-intern-sandbox-2912"
  default_tags {
    tags = {
      environment       = var.env_name
      region            = var.aws_region
      owner             = "mission-coliveros"
      project           = "argocd-demo-2023"
      terraform-managed = "true"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}