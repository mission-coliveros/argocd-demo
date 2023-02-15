env_name          = "dev"
aws_region        = "us-west-2"
vpc_subnet_prefix = "10.11"

custom_namespaces = [
  {
    name : "mission-api-test"
    labels : {
      "app" : "mission-api",
      "elbv2.k8s.aws/pod-readiness-gate-inject" : "enabled"
    }
  },
  {
    name : "mission-api-staging"
    labels : {
      "app" : "mission-api",
      "elbv2.k8s.aws/pod-readiness-gate-inject" : "enabled"
    }
  }
]