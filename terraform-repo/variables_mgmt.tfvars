env_name          = "mgmt"
vpc_subnet_prefix = "10.1"

deploy_argo_cd = true

# Manifests cannot be deployed until all dependent resources are present (Terraform quirk)
deploy_argo_manifests = true
deploy_eso_manifests  = true