locals {
  #Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  region = local.region_vars.locals.aws_region
  env    = local.environment_vars.locals.environment

  tags = {
    "Managed-by" : "terraform",
    "Environment" : local.env
  }
}

dependency "eks-cluster" {
  config_path                             =   "../cluster"
  mock_outputs_allowed_terraform_commands = ["validate"]
}

#Terragrunt will copy the terraform configurations specified by the source parameter, along with any files in the working directory into a temporary folder, and execute terraform commands in that folder.

terraform {
  source = "../EKS/alb-controller"
}

#include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


inputs = {
  cluster_name = dependency.eks-cluster.outputs.eks_cluster_name
  helm_chart_version = "1.7.2"
  cluster_identity_oidc_issuer = dependency.eks-cluster.outputs.eks_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = dependency.eks-cluster.outputs.eks_oidc_provider_arn
  cluster_certificate_authority_data = dependency.eks-cluster.outputs.cluster_certificate_authority_data
  cluster_endpoint = dependency.eks-cluster.outputs.cluster_endpoint
  tags = local.tags
  aws_region = local.region
}

