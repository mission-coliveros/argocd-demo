export ARGOCD_HOST="a37270e4597024f9299443e5a420ae3d-59344589.us-west-2.elb.amazonaws.com"

argocd login $ARGOCD_HOST --username "admin" --password "JhCtE2DUi4-RZhgT"

argocd cluster add arn:aws:eks:us-west-2:843238382912:cluster/argocd-demo-prod argocd-demo-prod
argocd cluster add arn:aws:eks:us-west-2:843238382912:cluster/argocd-demo-dev argocd-demo-dev
