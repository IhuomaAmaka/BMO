#Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuratiorfeed forward to the child modules.
locals {
  environment = "QA"
  domain= "mgmbmo.com"
}
