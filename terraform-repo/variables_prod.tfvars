env_name          = "prod"
vpc_subnet_prefix = "10.21"

#deploy_eso_manifests = false

custom_namespaces = [
  {
    name : "mission-api-prod-us-west-1"
    labels : {
      "app" : "mission-api",
      "elbv2.k8s.aws/pod-readiness-gate-inject" : "enabled"
    }
  },
  {
    name : "mission-api-prod-us-west-2"
    labels : {
      "app" : "mission-api",
      "elbv2.k8s.aws/pod-readiness-gate-inject" : "enabled"
    }
  }
]