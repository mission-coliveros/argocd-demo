set -e
set -o pipefail

export AWS_PROFILE=mission-internal-intern-sandbox-2912
export TF_CHDIR="../../"
export BUCKET_PREFIX="mission-argocd-demo"
export TF_ENV="${1}"

echo "AWS_PROFILE={$AWS_PROFILE}"

echo "------------------------------------ '${TF_ENV}' ------------------------------------"
echo "Initializing Terraform"
terraform -chdir=$TF_CHDIR init -reconfigure \
-backend-config="bucket=${BUCKET_PREFIX}-${TF_ENV}" -backend-config="key=${TF_ENV}/terraform.tfstate" \
> /dev/null

echo "Refreshing datasources"
terraform -chdir=$TF_CHDIR plan \
-target data.aws_eks_cluster_auth.this \
-var-file=variables_${TF_ENV}.tfvars \
> /dev/null

echo "Runnning 'tf plan'"
terraform -chdir=$TF_CHDIR plan \
-var-file=variables_${TF_ENV}.tfvars \
| grep -v 'id=' | grep -v 'Reading...'
