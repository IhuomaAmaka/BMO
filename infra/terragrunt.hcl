locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  
  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id = local.account_vars.locals.aws_account_id
  aws_region = local.region_vars.locals.aws_region
}

# Generate an AWS provider block
generate "provider" {
  path ="provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  #alias = "env"
  region = "${local.aws_region}"
}

provider "local" {}

EOF
}

#Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket = "${get_env("TG_BUCKET_PREFIX", "")}management-uw2-qa"
    key = "${path_relative_to_include()}${get_env("TG_SELECTED_WORKSPACE", "")}/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "management-terraform-locks"
    #profile = "mgmt"
  }
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
#
#GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child 'terragrunt.hcl" config via the include block
#
# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
)
