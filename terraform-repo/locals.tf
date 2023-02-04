locals {
  stack_env_name    = "${var.stack_name}-${var.env_name}"
  cluster_name      = local.stack_env_name
  state_bucket_path = local.stack_env_name

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