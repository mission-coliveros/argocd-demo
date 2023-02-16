export ARGOCD_HOST="a37270e4597024f9299443e5a420ae3d-59344589.us-west-2.elb.amazonaws.com"

argocd login $ARGOCD_HOST --username "admin" --password "JhCtE2DUi4-RZhgT" --insecure

argocd app create \
--file "../templates/mission-api.yaml" \
--revision "${1}" \
--name "${2}" \
--dest-namespace "${2}" \
--helm-set "common.environment_name=${3}" \
--helm-set "common.namespace=${4}" \
--helm-set "api.deployment.image.tag=${5}" \
--upsert

argocd app sync "${2}"

# sh add_ephemeral_app.sh "0.0.22" "mission-api-dev-cody" "mission-api" "mission-api-dev" "0.0.15"