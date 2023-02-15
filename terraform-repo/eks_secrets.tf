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

module "external_secrets_operator_service_account_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.1"

  role_name                              = "${local.cluster_name}-external-secrets-operator"
  role_policy_arns = {
    external_secrets: aws_iam_policy.external_secrets_operator.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-secrets-operator"]
    }
  }
}

resource "kubernetes_service_account" "external_secrets_operator" {
  metadata {
    name      = "external-secrets-operator"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "external-secrets-operator"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.external_secrets_operator_service_account_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "aws_iam_policy" "external_secrets_operator" {
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

resource "kubernetes_manifest" "external_secrets_operator_cluster_store" {
  count = var.deploy_eso_manifests ? 1 : 0
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
          "service" = "SecretsManager"
          "auth": {
            "jwt": {
              "serviceAccountRef": {
                "name": kubernetes_service_account.external_secrets_operator.metadata[0].name
                "namespace": kubernetes_service_account.external_secrets_operator.metadata[0].namespace
              }
            }
          }
        }
      }
    }
  }
}

#
resource "kubernetes_manifest" "external_secrets_operator_cluster_secret_mission_api" {
  count = var.deploy_eso_manifests ? 1 : 0

  depends_on = [ aws_secretsmanager_secret_version.mission_api ]
  manifest   = {
    "apiVersion" = "external-secrets.io/v1beta1"
    "kind"       = "ClusterExternalSecret"
    "metadata"   = {
      "name" = "mission-api"
    }
    "spec" = {
      "externalSecretName" : "mission-api"
      "namespaceSelector" : {
        "matchLabels" : { "app" : "mission-api" }
      }
      "refreshTime" : "1m"
      "externalSecretSpec" : {
        "dataFrom" = [
          { "extract" : { "key" : aws_secretsmanager_secret.mission_api.name } }
        ]
        "refreshInterval" = "5m"
        "secretStoreRef"  = {
          "kind" = "ClusterSecretStore"
          "name" = kubernetes_manifest.external_secrets_operator_cluster_store[0].manifest.metadata.name
        }
        "target" = {
          "creationPolicy" = "Owner"
          "name"           = "mission-api"
        }
      }
    }
  }
}

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