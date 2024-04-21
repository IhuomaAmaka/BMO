locals {
  env = var.environmentenv
  disk_size = try(var.eks_managed_node_group_defaults.disk_size, 50)
  instance_types = try(var.eks_managed_node_group_defaults.instance_types, ["m5a.xlarge", "m6i.large", "m5.large", "m5n.large", "t3a.large"])
  ami_type = try(var.eks_managed_node_group_defaults.ami_type,"AL2_x86_64")
  min_size = try(var.eks_managed_node_group_defaults.min_size, 1)
  max_size = try(var.eks_managed_node_group_defaults.max_size, 10)
  desired_size = try(var.eks_managed_node_group_defaults.desired_size, 2)
  capacity_type = try(var.eks_managed_node_group_defaults.capacity_type, "ON_DEMAND")
  ssm_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  autoscaling_policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  cloudwatch_policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  cognito_readonly_policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
    
  tags = merge({
    "Managed-by" : "terraform",
    "Environment" : local.env,
  },
  var.tags
  )
  eks_managed_node_groups_iam_role_arns = [for i in module.eks.eks_managed_node_groups : i.iam_role_arn]
}
