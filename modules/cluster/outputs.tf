output "eks_oidc_provider_arn" {
  value= module.eks.oidc_provider_arn
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_managed_node_groups_iam_role_arns" {
  value.= local.eks_managed_node_groups_iam_role_arns
}

output "eks_oidc_provider" {
  value = module.eks.oidc_provider
}

output "eks_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

