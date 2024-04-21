Locals {
  # Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  region = local.region_vars.locals.aws_region
  env    = local.environment_vars.locals.environment

  tags = {
    "Managed-by" : "terraform",
    "Environment”: local.env
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter,along with any files in the working directory, into a temporary folder,and execute your Terraform commands in that folder.
terraform {
  source = "../../EKS/aws-kms-keys"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the teeeagrunt configuration above
inputs = {
  keys = {
    "${local.env}-eks-main" = {
    description         = "KMS key for EKS resources",
    enable_key_rotation = true,
    multi_region        = true,
    tags                = merge(local.tags, {})
    }
  }
}




