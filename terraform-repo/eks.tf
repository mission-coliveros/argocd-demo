module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  # Base
  cluster_name    = local.cluster_name
  cluster_version = "1.24"
  cluster_addons  = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Encryption
  cluster_encryption_config = [
    {
      resources = [ "secrets" ]
    }
  ]
  create_kms_key                = true
  kms_key_enable_default_policy = true
  kms_key_administrators        = [
    data.aws_iam_role.mission_admin.arn
  ]

  # Access control
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Allow outbound traffic to nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Logging
  cluster_enabled_log_types = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]

  # Auth
  manage_aws_auth_configmap = true
  aws_auth_roles            = [
    {
      rolearn  = data.aws_iam_role.mission_admin.arn
      username = "mission-admin"
      groups   = [ "system:masters" ]
    }
  ]

  # VPC
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Nodes
  eks_managed_node_groups = {
    "argocd-${var.env_name}-general" = {
      "node-group-name" = "argocd-${var.env_name}-general"
      "min-size"        = "1"
      "desired-size"    = "2"
      "max-size"        = "5"
      "launch-template" = "false"
      "disk-size"       = "300"
      "capacity-type"   = "ON_DEMAND"
      "instance-types"  = [ "t3.small" ]
      "role"            = "argocd-${var.env_name}-general"
      "ami-type"        = "AL2_x86_64"
    }
  }
}

# Create secret of kubeconfig, to be passed into Argo management cluster
module "eks_kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "2.0.0"

  cluster_name = module.eks.cluster_id
}

resource "aws_secretsmanager_secret" "kubeconfig" {
  name = "argocd/clusters/kubeconfigs/${module.eks.cluster_id}"
}

resource "aws_secretsmanager_secret_version" "kubeconfig" {
  lifecycle { ignore_changes = [ secret_string ] }
  secret_id     = aws_secretsmanager_secret.kubeconfig.id
  secret_string = module.eks_kubeconfig.kubeconfig
}