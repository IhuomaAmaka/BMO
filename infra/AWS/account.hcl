# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root terragrunt.hcl configuration.
locals {
  account_name = "762568804439"
  aws_account_id = "762568804439"
  mgmt_vpc_cidrs  =["10.50.64.0/20"]
  on_prem_network_cidrs = ["10.40.0.0/16"]
  default_rt = ["0.0.0.0/0"]
}
