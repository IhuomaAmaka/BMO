locals {
  # Automatically load environment-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  region         = local.region_vars.locals.aws_region
  mgmt_vpc_cidrs = local.account_vars.locals.mgmt_vpc_cidrs
  env            = local.environment_vars.locals.environment

  tags = {
    "Managed-by" : "terraform",
    "Environment" : local.env
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../network/security-groups"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../network/vpc"
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id = "vpc-0daa5818cd1d59ae0"
    vpc_cidr_block = ["10.50.64.0/20"]
  }
}
  
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs= {
  region = local.region
  security_groups = [
    {
      name = "IaaS Access",
      description = "for Iaas Access",
      vpc_id = dependency.vpc.outputs.vpc_id,
      tags = merge(local.tags, {})
      ingress_with_cidr_blocks = [
        {
          from_port = 22
          to_port = 22
          protocol = 6
          description = "Allow SSH Outbound
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port = 3389
          to_port = 3389
          protocol = 6
          description = "Allow RDP inbound"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port = 443
          to_port = 443
          protocol = 6
          description = HTTPS for web management"
          cidr_blocks = "0.0.0.0/0"
        }
      ],
      egress_with_cidr_blocks = [
        {
          from_port = 0
          to_port = 65535
          protocol = 6
          description = "Allow all egress traffic"
          cidr_blocks = "0.0.0.0/0"
        }
      ]
    }
  ] 
  tags = local.tags
}
