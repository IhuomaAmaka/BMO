locals {
  # Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Extract out common variables for reuse
  region = local.region_vars.locals.aws_region
  env = local.environment_vars.locals.environment
  
  tags= {
  "Managed-by”: "terraform",
  "Environment" : local.env,

  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter,along with any files in the working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source="tfr:///terraform-aws-modules/iam/aws//modules/iam-policy?version-5.30.0"
}

# Include all settings from the root terragrunt.hcl file
include{
  path= find_in_parent_folders()
}
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name= "external-secrets-policy"
  description = "Policy for external secrets to access secrets manager"
  policy = <<EOF
{
  "Statement": [
    {
      "Action":[
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:*:*:parameter/*"
    },
    {
      "Action": "secretsmanager:ListSecrets",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action":[
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:GetSecretValue",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:DescribeSecret"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:*:*:secret:*"
    }
  ],
  "Version": "2012-10-17"
}
EOF
tags = local.tags
}

