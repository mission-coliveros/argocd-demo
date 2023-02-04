export AWS_PROFILE=mission-internal-intern-sandbox-2912
export TERRAFORM_ENVIRONMENT_NAME=shared
export TF_CHDIR="../../"

terraform -chdir=$TF_CHDIR init -migrate-state \
-backend-config="workspace_key_prefix=${TERRAFORM_ENVIRONMENT_NAME}"

terraform -chdir=$TF_CHDIR plan \
-var-file=variables_${TERRAFORM_ENVIRONMENT_NAME}.tfvars