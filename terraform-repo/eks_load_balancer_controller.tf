locals {
  awsLbcRepos = {
    "af-south-1" : "877085696533.dkr.ecr.af-south-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-east-1" : "800184023465.dkr.ecr.ap-east-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-northeast-1" : "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-northeast-2" : "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-northeast-3" : "602401143452.dkr.ecr.ap-northeast-3.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-south-1" : "602401143452.dkr.ecr.ap-south-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-southeast-1" : "602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "ap-southeast-2" : "602401143452.dkr.ecr.ap-southeast-2.amazonaws.com/amazon/aws-load-balancer-controller",
    "ca-central-1" : "602401143452.dkr.ecr.ca-central-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "cn-north-1" : "918309763551.dkr.ecr.cn-north-1.amazonaws.com.cn/amazon/aws-load-balancer-controller",
    "cn-northwest-1" : "961992271922.dkr.ecr.cn-northwest-1.amazonaws.com.cn/amazon/aws-load-balancer-controller",
    "eu-central-1" : "602401143452.dkr.ecr.eu-central-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "eu-north-1" : "602401143452.dkr.ecr.eu-north-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "eu-south-1" : "590381155156.dkr.ecr.eu-south-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "eu-west-1" : "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "eu-west-2" : "602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller",
    "eu-west-3" : "602401143452.dkr.ecr.eu-west-3.amazonaws.com/amazon/aws-load-balancer-controller",
    "me-south-1" : "558608220178.dkr.ecr.me-south-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "sa-east-1" : "602401143452.dkr.ecr.sa-east-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-east-1" : "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-east-2" : "602401143452.dkr.ecr.us-east-2.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-gov-east-1" : "151742754352.dkr.ecr.us-gov-east-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-gov-west-1" : "013241004608.dkr.ecr.us-gov-west-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-west-1" : "602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon/aws-load-balancer-controller",
    "us-west-2" : "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
  }
}

module "load_balancer_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.1"

  role_name                              = "${local.cluster_name}-lbc"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.load_balancer_controller_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [kubernetes_service_account.load_balancer_controller]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "image.repository"
    value = local.awsLbcRepos[var.aws_region]
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}
