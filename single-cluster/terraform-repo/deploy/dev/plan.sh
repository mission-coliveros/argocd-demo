export AWS_PROFILE=mission-internal-intern-sandbox-2912
export TERRAFORM_ENVIRONMENT_NAME=dev
export TF_CHDIR="../../"

terraform -chdir=$TF_CHDIR init -reconfigure \
-backend-config="key=${TERRAFORM_ENVIRONMENT_NAME}/terraform.tfstate"

terraform -chdir=$TF_CHDIR plan -target data.aws_eks_cluster_auth.this \
-var-file=variables_${TERRAFORM_ENVIRONMENT_NAME}.tfvars
