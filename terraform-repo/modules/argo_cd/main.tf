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

resource "kubernetes_manifest" "argocd_projects" {
  count = var.deploy_argo_manifests ? 1 : 0

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = "projects"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source"  = {
        "path"           = "argocd-repo/projects"
        "repoURL"        = "https://github.com/mission-coliveros/argocd-demo.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_application_demo" {
  count = var.deploy_argo_manifests ? 1 : 0

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = "mission-api"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source"  = {
        "path"           = "argocd-repo/applications/mission-api"
        "repoURL"        = "https://github.com/mission-coliveros/argocd-demo.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = {
        "automated" = {}
      }
    }
  }
}
