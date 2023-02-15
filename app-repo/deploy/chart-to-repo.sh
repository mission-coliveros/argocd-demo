set -e
set -o pipefail

export HELM_PATH="../helm/api"
export APP_VERSION='0.0.22'
export CHART_VERSION='0.0.22'

export AWS_PROFILE=mission-internal-intern-sandbox-2912
export AWS_REGION='us-west-2'
export AWS_ACCOUNT_ID='843238382912'
export AWS_ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export AWS_ECR_REPO="${AWS_ECR_REGISTRY}/mission-api-helm"


# Lint chart
helm lint ${HELM_PATH}

# Package API
helm package ${HELM_PATH} --app-version "${APP_VERSION}" --version "${CHART_VERSION}"

# Login to Helm repo
aws ecr get-login-password \
--region "${AWS_REGION}" | helm registry login \
--username AWS \
--password-stdin "${AWS_ECR_REGISTRY}"

# Push to repository
helm push "mission-api-helm-${CHART_VERSION}.tgz" "oci://${AWS_ECR_REGISTRY}/"

# Cleanup
rm "mission-api-helm-${CHART_VERSION}.tgz"
helm registry logout "${AWS_ECR_REGISTRY}"