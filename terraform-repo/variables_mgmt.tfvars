env_name          = "mgmt"
vpc_subnet_prefix = "10.1"
aws_region        = "us-west-2"


deploy_argo_cd = true
#deploy_argo_manifests  = false # Toggle on after cluster is created.  Cannot be enabled before cluster is applied
#argocd_target_clusters = [""]

deploy_eso_manifests = false