locals {
  #Automatically load environment-level variables
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  region = local.region_vars.locals.aws_region
  env    = local.environment_vars.locals.environment
  accountid    = local.account_vars.locals.aws_account_id

  tags = {
    "Managed-by" : "terraform",
    "Environment" : local.env
  }
}

# Declare dependencies
dependency "vpc" {
  config_path                             =   "../network/vpc"
  mock_outputs_allowed_terraform_commands = ["validate"]
}

dependency "kms" {
  config_path                             =   "../kms/keys"
  mock_outputs_allowed_terraform_commands = ["validate"]
}


#Terragrunt will copy the terraform configurations specified by the source parameter, along with any files in the working directory into a temporary folder, and execute terraform commands in that folder.

terraform {
  source = "../../EKS/cluster"
}

#include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


inputs = {
  cluster_name = payment-management-cluster
  cluster_region = local.region
  environment = local.env
  kms_arn = dependency.kms.outputs.key_arns["${local.env}-eks-mgmt"]
  vpc_id = dependency.vpc.outputs.private_subnets
  subnet_ids = dependency.vpc.outputs.vpc_id
  ebs_csi_role_name = "ebs_csi_role"
  efs_csi_role_name = "efs_csi_role"
  vpc_cni_role_name = "vpc_cni_role"
  allow https_cidr_blocks = [10.40.0.0/24]
  cluster_addons_versions = {
    coredns             = "v1.10.1-eksbuild.4"
    kube-proxy          = "v1.27.6-eksbuild.2"
    vpc-cni             = "v1.15.1-eksbuild.1"
    aws-ebs-csi-driver  = "v1.27.0-eksbuild.1"
    aws-efs-csi-driver  = "v1.7.4-eksbuild.1"
  }
  eks_manages_node_groups = {
    "QA-1" = {}
    "QA-2" = {}
  }
  access_entries = {
  #One access entry with a policy associated
    ClusterAdmin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::762568804439:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSPowerUserAccess_81c72725b1207e66"
      policy_associations = {
        ClusterAdmin = {
	  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
	  access_scope = {
	    type = "cluster"
	  }
	}
      }
    }
  }
  tags = local.tags
}



