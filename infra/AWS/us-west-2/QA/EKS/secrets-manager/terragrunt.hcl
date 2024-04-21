locals {
  # Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hc1"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  region    = local.region_vars.locals.aws_region
  env       = local.environment_vars.locals.environment
  accountid = local.account_vars.locals.aws_account_id

  tags = {
    "Managed-by”:"terraform",
    "Environment":local.env
  }
}

# # Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../EKS/aws-secrets"
}

inputs = {
  secrets = {
    login-service = {
      name             = "login-service-${local.region}-${local.env}
      secret_string    = "placeholder"
    }
    registration-service = {
      name             = "registration-service-${local.region}-${local.env}
      secret_string    = "placeholder"
    }
    payment-service = {
      name             = "payment-service-${local.region}-${local.env}
      secret_string    = "placeholder"
    }
  }
  tags = local.tags
}
