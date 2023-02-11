set -e
set -o pipefail

export HELM_PATH="../helm/api"
export APP_VERSION='0.0.2'
export CHART_VERSION='0.0.2'
export APP_ENVIRONMENT="dev01"
export KUBE_CONTEXT="arn:aws:eks:us-west-2:843238382912:cluster/argocd-demo-dev"



kubectl config use-context "${KUBE_CONTEXT}"
kubectl get pods --all-namespaces

# Lint chart
helm lint "${HELM_PATH}"

# Package API
helm package ${HELM_PATH} --app-version "${APP_VERSION}" --version "${CHART_VERSION}"

if [ "${1}" == "deploy" ];
then
  echo "Deploying Helm chart"
  ## Push to repository
  helm install -f "${HELM_PATH}/values-${APP_ENVIRONMENT}.yaml" -n "mission-api" \
    argocd-fastapi-test "${HELM_PATH}" --kube-context="${KUBE_CONTEXT}"
fi

if [ "${1}" == "update" ];
then
  echo "Updating Helm chart"
  ## Push to repository
  helm update -f "${HELM_PATH}/values-${APP_ENVIRONMENT}.yaml" -n "mission-api" \
    argocd-fastapi-test "${HELM_PATH}" --kube-context="${KUBE_CONTEXT}"
fi

## Cleanup
rm "mission-api-helm-${CHART_VERSION}.tgz"
