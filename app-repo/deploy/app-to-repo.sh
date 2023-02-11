set -e
set -o pipefail

export ROOT_PATH="../"
export IMAGE_NAME="mission-api"
export IMAGE_TAG="0.0.11"

export AWS_PROFILE=mission-internal-intern-sandbox-2912
export AWS_REGION='us-west-2'
export AWS_ACCOUNT_ID='843238382912'
export AWS_ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export AWS_ECR_REPO="${AWS_ECR_REGISTRY}/mission-api"


# Build image
docker buildx build --platform=linux/amd64 -t "${AWS_ECR_REPO}:${IMAGE_TAG}" ${ROOT_PATH}

# Login to Helm repo
aws ecr get-login-password \
--region "${AWS_REGION}" | \
docker login --username AWS --password-stdin "${AWS_ECR_REGISTRY}"

# Push to repository
docker image push "${AWS_ECR_REPO}:${IMAGE_TAG}"

# Cleanup
docker logout "${AWS_ECR_REGISTRY}"
