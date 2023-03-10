set -e
set -o pipefail

export AWS_PROFILE=mission-internal-intern-sandbox-2912
export TF_CHDIR="../"
export BUCKET_PREFIX="mission-argocd-demo"
export TF_ENV="${1}"

echo "------------------------------------ '${TF_ENV}' ------------------------------------"

terraform -chdir=$TF_CHDIR init -reconfigure \
-backend-config="bucket=${BUCKET_PREFIX}-${TF_ENV}" -backend-config="key=${TF_ENV}/terraform.tfstate" \
> /dev/null

terraform -chdir=$TF_CHDIR plan \
-target data.aws_eks_cluster_auth.this \
-var-file=variables_${TF_ENV}.tfvars \
> /dev/null

terraform -chdir=$TF_CHDIR destroy \
-var-file=variables_${TF_ENV}.tfvars
