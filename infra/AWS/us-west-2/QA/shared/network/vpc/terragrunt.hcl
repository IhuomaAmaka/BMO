locals {
  # Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Extract out common variables for reuse
  region = local.region_vars.locals.aws_region
  env    = local.environment_vars.locals.environment

  tags = {
    "Managed-by”: "terraform",
    "Environment": local.env
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter,along with any files in the working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//.?version=5.2.0"
}

# Include all settings from the root terragrunt.hcl file
include{
  path = find_in_parent_folders()
}

# These are the varlables we have to pass in to use the module specified in the terragrunt configuration abeve

inputs = {
  name = "QA-VPC"
  cidr = "10.50.64.0/20"

  azs = ["${local.region}a", "${local.region}b"]
  private_subnets = [
    "10.50.64.0/24",
    "10.50.65.0/24"
  ]
  intra_subnets = [
    "10.50.66.0/24",
    "10.50.67.0/24"
  ]
  public_subnets = [
  ]
  enable_nat_gateway                   = false
  single_nat_gateway                   = false
  enable_internet_gateway              = false
  enable_vpn_gateway                   = false
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
  tags = merge(local.tags, {})
}
