#### cluster autoscaler ####
module "cluster_autoscaler_irsa_role" {
  count                                  = (local.enable_ca_role && var.enable_ca) ? 1 : 0
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                                = “5.28.0”
  role_name                              = "${local.eks_cluster_name}-ClusterAutoscalerRole"
  attach_cluster_autoscaler_policypolicy = true
  cluster_autoscaler_cluster_names       = [local.eks_cluster_name]
  policy_name_prefix                     = "${local.eks_cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = local.cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["${var.ca_namespace}:${var.ca_service_account_name}"]
    }
  }
}

#### create namespace ####
resource "kubernetes_namespace" "cluster_autoscaler" {
  count = (var.enable_ca && var.create_ca_namespace && var.ca_namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.ca_namespace
  }
}

# helm chart #
resource "helm_release" "cluster_autoscaler" {
  depends_on = [kubernetes_namespace.cluster_autoscaler]
  count      = var.enable_ca ? 1 : 0
  name       = var.ca_helm_chart_name
  chart      = var.ca_helm_chart_release_name
  repository = var.ca_helm_repo
  version    = var.ca_helm_chart_version
  namespace  = var.ca_namespace

  set {
    name  = "fullnameOverride"
    value = var.ca_helm_fullname_override
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.eks_cluster_name
  }

  set {
    name  = "awsRegion"
    value = local.eks_region
  }

  set {
    name  = "rbac.serviceAccorunt.name"
    value = var.ca_service_account_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa_role[0].iam_role_arn
  }

  values = [
    yamlencode(var.settings)
  ]
}

