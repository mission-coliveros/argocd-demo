# -------------------------
# Core resources
# -------------------------

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = var.argocd_service_type # ClusterIP, NodePort, LoadBalancer, ExternalName
  }
}

# -------------------------
# Argo ECR updater extension
# -------------------------

resource "aws_iam_policy" "argocd_ecr_updater" {
  name   = "${var.env_name}-argocd-updater-temp"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EcrUpdaterPermissions",
        "Effect" : "Allow",
        "Action" : [
          "ecr:ListTagsForResource",
          "ecr:ListImages",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetLifecyclePolicy",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : var.ecr_updater_repos
      }
    ]
  })
}

resource "helm_release" "argocd_ecr_updater" {
  name       = "argocd-ecr-updater"
  repository = "https://karlderkaefer.github.io/argocd-ecr-updater"
  chart      = "argocd-ecr-updater"
  version    = var.argocd_ecr_updater_chart_version
  namespace  = helm_release.argocd.namespace
}

# -------------------------
# Argo repositories
# -------------------------

resource "kubernetes_secret_v1" "gitops_repo" {

  metadata {
    namespace     = helm_release.argocd.namespace
    generate_name = "repo-"
    labels        = {
      "argocd.argoproj.io/secret-type" : "repository"
    }
    annotations = {
      "managed-by" = "argocd.argoproj.io"
    }
  }

  data = {
    enableLfs : "true",
    insecure : "true",
    project : "default",
    type : "git",
    url : "https://github.com/mission-coliveros/argocd-demo.git"
    username : var.gitops_repo_username
    password : var.gitops_repo_password
  }
}

resource "kubernetes_secret_v1" "demo_api_repo" {
  lifecycle { ignore_changes = [data] }

  metadata {
    generate_name = "repo-"
    namespace     = helm_release.argocd.namespace
    labels        = {
      "argocd-ecr-updater" : "enabled"
      "argocd.argoproj.io/secret-type" : "repository"
    }
    annotations = {
      "managed-by" = "argocd.argoproj.io"
    }
  }

  data = {
    url : "https://${var.ecr_registry}",
    name : var.image_repo_name,
    type : "helm",
    password : "",
    username : "AWS",
  }
}

# -------------------------
# Argo workloads
# -------------------------

resource "kubernetes_manifest" "argocd_application_demo" {
  count = var.deploy_argo_manifests ? 1 : 0

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = "demo"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source"  = {
        "helm" = {
          "valueFiles" = [
            "values-${var.env_name}.yaml",
          ]
        }
        "path"           = "argo_cd/apps/demo"
        "repoURL"        = "https://github.com/mission-coliveros/argocd-demo.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}
#
#resource "kubernetes_manifest" "argocd_applicationset" {
#  count = var.deploy_argo_manifests ? 1 : 0
#
#  manifest = {
#    "apiVersion" = "argoproj.io/v1alpha1"
#    "kind"       = "ApplicationSet"
#    "metadata"   = {
#      "name" = "demo"
#    }
#    "spec" = {
#      "generators" : {
#        "list" : {
#          "elements" : [
#            {
#              "cluster" : "argocd-demo-prod"
#              "url" : "https://2D5AF68D64DDEEEC928AFCA8D89DED39.gr7.us-west-2.eks.amazonaws.com"
#              "valuesFile" : "production"
#              "namespace" : "mission-api"
#            },
#            {
#              "cluster" : "argocd-demo-dev"
#              "url" : "https://F40F64ECB7956B66F6DE3604BD41EA54.sk1.us-west-2.eks.amazonaws.com"
#              "valuesFile" : "dev01"
#              "namespace" : "mission-api-dev01"
#            },
#            {
#              "cluster" : "argocd-demo-dev"
#              "url" : "https://F40F64ECB7956B66F6DE3604BD41EA54.sk1.us-west-2.eks.amazonaws.com"
#              "valuesFile" : "dev02"
#              "namespace" : "mission-api-dev02"
#            }
#          ]
#        }
#      }
#      "template" : {
#        "metadata" : {
#          "name" : '{{cluster}}-guestbook'
#        }
#        "spec" : {
#          "project" : "{{cluster}}"
#          "source" : {
#            "repoURL" : "https://github.com/argoproj/argo-cd.git"
#            "targetRevision" : "HEAD"
#            "path" : "applicationset/examples/list-generator/guestbook/{{cluster}}"
#          }
#          "destination": {
#            "server": '{{url}}'
#            "namespace": "{{namespace}}"
#          }
#        }
#      }
#    }
#  }
#}

#apiVersion: v1
#kind: Secret
#metadata:
#  name: mycluster-secret
#  labels:
#    argocd.argoproj.io/secret-type: cluster
#type: Opaque
#stringData:
#  name: mycluster.com
#  server: https://mycluster.com
#  config: |
#    {
#      "existingKubeconfigSecret": "mycluster-kubeconfig"
#    }

#resource "kubernetes_secret_v1" "dev_cluster" {
#
#  lifecycle { ignore_changes = [data] }
#
#  metadata {
#    name      = "cluster-${data.aws_eks_cluster.dev.id}"
#    namespace = helm_release.argocd.namespace
#    labels    = {
#      "argocd.argoproj.io/secret-type" : "cluster"
#    }
#    annotations = {
#      "managed-by" = "argocd.argoproj.io"
#    }
#  }
#
#  data = {
#    name   = data.aws_eks_cluster.dev.id
#    server = data.aws_eks_cluster.dev.endpoint
#    config = data.aws_secretsmanager_secret_version.dev_kubeconfig.secret_string
#  }
#}
#
#resource "kubernetes_secret_v1" "prod_cluster" {
#
#  lifecycle { ignore_changes = [data] }
#
#  metadata {
#    name      = "cluster-${data.aws_eks_cluster.prod.id}"
#    namespace = helm_release.argocd.namespace
#    labels    = {
#      "argocd.argoproj.io/secret-type" : "cluster"
#    }
#    annotations = {
#      "managed-by" = "argocd.argoproj.io"
#    }
#  }
#
#  data = {
#    name   = data.aws_eks_cluster.prod.id
#    server = data.aws_eks_cluster.prod.endpoint
#    config = data.aws_secretsmanager_secret_version.prod_kubeconfig.secret_string
#  }
#}