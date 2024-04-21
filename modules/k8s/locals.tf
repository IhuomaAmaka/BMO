locals {
  eks_cluster_endpoint             = var.eks_outputs.cluster_endpoint
  eks_cluster_name                 = var.eks_outputs.eks_cluster_name
  eks_cluster_auth_data            = var.eks_outputs.cluster_certificate_authority_data
  eks_region                       = var.cluster_region
  cluster_identity_oidc_issuer     = var.eks_outputs.eks_oidc_provider
  cluster_identity_oidc_issuer_arn = var.eks_outputs.eks_oidc_provider_arn

  argocd_add_cluster = var.argocd_add
  argocd_eks_cluster = local.argocd_add_cluster ? var.argocd_eks_cluster_name : ""
  argocd_profile     = var.argocd_profile
  argocd_region      = var.argocd_region
  lb_subnets         = length(var.lb_subnets) > 0 ? var.lb_subnets : var.vpc_outputs.private_subnets
  
  enable_ca_role = var.enable_ca ? true : false
}
