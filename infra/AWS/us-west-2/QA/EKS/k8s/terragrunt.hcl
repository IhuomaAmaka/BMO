locals {
  # Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  region    = local.region_vars.locals.aws_region
  env       = local.environment_vars.locals.environment
  accountid = local.account_vars.locals.aws_account_id 

  tags = {
    "Managed-by":"terraform”,
    "Environment":local.env,
  }
}

# Declare dependencies
dependency "vpc” {
  config_path = "../network/vpc
  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "eks" {
  config_path="../cluster"
  mock_outputs_allowed_terraform_commands = ["validate"]
}

# # Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../EKS/cluster"
}

inputs = {
  eks_outputs = dependency.eks.outputs
  vpc_outputs = dependency.vpc.outputs
  cluster_region = local.region
  argocd_add_cluster = true
  argocd_eks_cluster_name = “devops-mgmt-cluster"
  tags = local.tags
}
