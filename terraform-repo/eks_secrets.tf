resource "helm_release" "external_secrets_operator" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  version          = "0.7.2"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

#  name       = "aws-load-balancer-controller"
#  repository = "https://aws.github.io/eks-charts"
#  chart      = "aws-load-balancer-controller"
#  namespace  = "kube-system"
#  depends_on = [kubernetes_service_account.load

resource "aws_iam_user" "external_secrets_operator" {
  name = "${local.stack_env_name}-external-secrets-operator"
}

resource "aws_iam_user_policy" "external_secrets_operator" {
  user   = aws_iam_user.external_secrets_operator.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${local.stack_env_name}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "external_secrets_operator" {
  user = aws_iam_user.external_secrets_operator.name
}

resource "kubernetes_secret" "external_secrets_operator_aws_credentials" {
  metadata {
    name      = "external-secrets-operator-aws-credentials"
    namespace = "external-secrets"
  }
  type = "Opaque"
  data = {
    "KEYID" : aws_iam_access_key.external_secrets_operator.id
    "SECRETKEY" : aws_iam_access_key.external_secrets_operator.secret
  }
}

resource "kubernetes_manifest" "external_secrets_operator_cluster_store" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterSecretStore"
    "metadata"   = {
      "name" = "eso-aws-secrets-manager"
    }
    "spec" = {
      "conditions" : [
        {
          "namespaceSelector" : {
            "matchLabels" : { "app" : "mission-api" }
          }
        }
      ]
      "provider" = {
        "aws" = {
          "region" : var.aws_region
          "auth" = {
            "secretRef" = {
              "accessKeyIDSecretRef" = {
                "key"  = "KEYID"
                "name" = kubernetes_secret.external_secrets_operator_aws_credentials.metadata[ 0 ].name
                "namespace": "external-secrets"
              }
              "secretAccessKeySecretRef" = {
                "key"  = "SECRETKEY"
                "name" = kubernetes_secret.external_secrets_operator_aws_credentials.metadata[ 0 ].name
                "namespace": "external-secrets"
              }
            }
          }
          "region"  = var.aws_region
          "service" = "SecretsManager"
        }
      }
    }
  }
}
#
#resource "kubernetes_manifest" "external_secrets_operator_cluster_secret_mission_api" {
#  depends_on = [ aws_secretsmanager_secret_version.mission_api ]
#  manifest   = {
#    "apiVersion" = "external-secrets.io/v1beta1"
#    "kind"       = "ClusterExternalSecret"
#    "metadata"   = {
#      "name" = "mission-api"
#    }
#    "spec" = {
#      "externalSecretName" : "mission-api"
#      "namespaceSelector" : {
#        "matchLabels" : { "app" : "mission-api" }
#      }
#      "refreshTime" : "1m"
#      "externalSecretSpec" : {
#        "dataFrom" = [
#          { "extract" : { "key" : aws_secretsmanager_secret.mission_api.name } }
#        ]
#        "refreshInterval" = "5m"
#        "secretStoreRef"  = {
#          "kind" = "ClusterSecretStore"
#          "name" = kubernetes_manifest.external_secrets_operator_cluster_store.manifest.metadata.name
#        }
#        "target" = {
#          "creationPolicy" = "Owner"
#          "name"           = "mission-api"
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "external_secrets_operator_secret_mission_api" {
#  depends_on = [ aws_secretsmanager_secret_version.mission_api ]
#  manifest   = {
#    "apiVersion" = "external-secrets.io/v1beta1"
#    "kind"       = "ExternalSecret"
#    "metadata"   = {
#      "name" = "mission-api"
#      "namespace" : "mission-api"
#    }
#    "spec" = {
#      "dataFrom" = [
#        { "extract" : { "key" : aws_secretsmanager_secret.mission_api.name } }
#      ]
#      "refreshInterval" = "5m"
#      "secretStoreRef"  = {
#        "kind" = "ClusterSecretStore"
#        "name" = kubernetes_manifest.external_secrets_operator_cluster_store.manifest.metadata.name
#      }
#      "target" = {
#        "creationPolicy" = "Owner"
#        "name"           = "mission-api"
#      }
#    }
#  }
#}

resource "aws_secretsmanager_secret" "mission_api" {
  name = "${local.stack_env_name}/cluster-secrets/mission-api-01"
}

resource "aws_secretsmanager_secret_version" "mission_api" {
  secret_id     = aws_secretsmanager_secret.mission_api.id
  secret_string = jsonencode({
    "POSTGRES_USERNAME" : "admin"
    "POSTGRES_PASSWORD" : "admin"
    "POSTGRES_HOST_AUTH_METHOD": "trust"
    "POSTGRES_DB": "postgres"
  })
}