module “eks" {
  source= "terraform-aws-modules/eks/aws"
  version = "19.15.2"
  cluster_name= var.cluster_name
  cluster_version = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  cluster_enabled_log_types = var.cluster_enabled_log_types

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version = var.cluster_addons_versions.coredns
    }

    kube-proxy = {
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version = var.cluster_addons_versions.kube-proxy
    }
  
    vpc-cni = {
      resolve_conflicts_on_update = "OVERWRITE"
      addon_version = var.cluster_addons_versions.vpc-cni
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
    }

    aws_ebs_csi-driver = {
      resolve_conflicts_on_update = "OVERWRITE"
      addon_ver sion= var.cluster_addons_versions.aws-ebs-csi-driver
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }
  
  cluster_ip_family = "ipv4"
  subnet_ids = var.subnet_ids
  vpc_id = var.vpc_id
  control_plane_subnet_ids = var.control_plane_subnet_ids

# kms key encryption
  create_kms_key = var.create_kms_key
  cluster_encryption_config = var.create_kms_key ? {resources = ["secrets"], provider_key_arn = null} : {resources = ["secrets"],  provider_key_arn = var.kms_arn }


# security group #
  cluster_security_group_use_name_prefix = false
  node_security_group_use_name_prefix = false
  
  cluster_security_group_additional_rules = {
    ingress_nodes_vpn=
      description = "Allow https for cluster access"
      protocol = "tcp"
      from_port = 443
      to_port = 443
      type = "ingress"
      cidr_blocks = var.allow_https_cidr_blocks
    }
  }

# EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    security_group_use_name_prefix = false
    disk_size = local.disk_size
    instance_types = local.instance_types
    ami_type = local.ami_type
    iam_role_additional_policies = {
    SSMFullAccess = local.ssm_policy_arn
    AutoScalingFullAccess = local.autoscaling_policy_arn
    CloudWatchFullAccess = local.cloudwatch_policy_arn
    AmazonCognitoReadOnly = local.cognito_readonly_policy_arn
    }

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs= {
          volume_size = 100
          volume_type = "gp3"
          iops = 3000
          throughput = 150
          # encrypted = true
          # kms_key_id = module.ebs_kms_key.key_arn
          delete_on_termination = true
        }
      }
    }
  }

  
  eks_managed_node_groups = { for k, v in var.eks_managed_node_groups :
    k => {
      "disk_size" = try(v.disk_size, local.disk_size)
      "min_size" = try(v.min_size, local.min_size)
      "max_size" = try(v.max_size, local.max_size)
      "desired_size" =try(v.desired_size, local.desired_size)
      "capacity_type" = try(v.capacity_type, local.capacity_type)
      "instance_types" = try(v.instance_types, local.instance_types)
      "ami_type" = try(v.ami_type, local.ami_type)
      "subnet_ids" = try(v.subnet_id, var.subnet_ids)
      "name" = "${var.cluster_name}-${k}-ng"
      "use_name_prefix" = false
      "iam_role_name" = "${var.cluster_name}-${k}-ng"
      "iam_role_use_name_prefix" = false
      "launch_template_name"= "${var.cluster_name}-${k}-ng-lt"
      "launch template use name prefix" = false
      

      tags = merge(
        try(v.tags, {}),
        local.tags
      )
    }
  }
  
  access_entries = var.access_entries
  tags = merge(local.tags,{
    Name = "${var.cluster_name}"
  })

}

      


