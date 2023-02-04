module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                 = local.stack_env_name
  azs                  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true

  cidr = "${var.vpc_subnet_prefix}.0.0/16"
  private_subnets = [
    "${var.vpc_subnet_prefix}.1.0/24",
    "${var.vpc_subnet_prefix}.2.0/24"
  ]
  public_subnets = [
    "${var.vpc_subnet_prefix}.11.0/24",
    "${var.vpc_subnet_prefix}.12.0/24",
  ]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal_elb"             = 1
  }
}
