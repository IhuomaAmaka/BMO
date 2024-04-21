## cluster role ##
resource "kubernetes_cluster_role" "argocd_manager" {
  count = local.argocd_add_cluster  ? 1 : 0
  metadata{
    name = "argocd-manager-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule{
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

## cluster role binding ##
resource "kubernetes_cluster_role_binding" "argocd_manager" {
  count = local.argocd_add_cluster ? 1 : 0
  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_manager[0].metadata[0].name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_servvice_account_v1.argocd_manager[0].metadata[0].name
    namespace = kubernetes_senvice_account_v1.argocd_manager[0].metadata[0].namespace

## kubernetes secret ##
resource "kubernetes_secret_v1" "argocd_manager" {
  count = local.argocd_add_cluster ? 1 : 0
  metadata {
    name        = "${kubernetes_service_account_v1.argocd_manager[0].metadata[0].name}-token"
    namespace   = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "argocd-manager"
    }
  } 
  type = "kubernetes.io/service-account-token"

## kubernetes service account ##
resource "kubernetes_service_account_v1" "argocd_manager" {
  count = local.argocd_add_cluster? 1 : 0
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
}

  secret {
    name = "argocd-manager-token"
  }
}

#### secret in argocd eks side where we have argocd ##
resource "kubernetes_secret_v1" "argocd_cluster_secret" {
  count = local.argocd_add_cluster ? 1 : 0
  metadata {
    name      = "${local.eks_cluster_name}-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }
  
  data = {
    name   = local.eks_cluster_name
    server = local.eks_cluster_endpoint
    config = jsonencode({
      "bearerToken" = nonsensitive(kubernetes_secret_v1.argocd_manager[0].data["token"])
      "tlsClientConfig" = {
        "insecure"= false
        "caData" = base64encode(nonsensitive(kubernetes_secret_v1.argocd_manager[0].data["ca.crt"]))
        "serverName" = "kubernetes.default.svc.cluster.local"
      }
    })
  }
  provider = kubernetes.argocd
}
provider "aws" {
  region  = local.argocd_region
  profile = local.argocd_profile
  alias   = "argocd"
}

