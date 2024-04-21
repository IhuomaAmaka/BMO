variable "eks" {
  description = "eks cluster attributes"
  type = any
  default = {}
}

# Cluster

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type = string
}

variable "efs_csi_role_name" {
  description = "Name of the EFS CSI role to be created"
  type = string
  default = "efs-csi"
}

variable "ebs_csi_role_name" {
  description = "Name of the EBS CSI role to be created"
  type = string
  default = "ebs-csi"
}

variable "vpc_cni_role_name" {
  description = "Name of the VPC CNI role to be created"
  type = string
  default = "vpc-cni"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>' version to use for the EKS cluster (i.e.: "1.27")”
  type = string
  default = "1.27"
}

variable "cluster_addons_versions" {
  description = "Kubernetes addons versions"
  type = map(string)
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type = bool
  default = true
}

variable “cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type = bool
  default = false
}


variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Ptype= list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler]
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type = list(string)
  default = []
}

variable "subnet_ids" {
  description"A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids=" is not  provided, then cluster subnets will be considered"
  type= list(string)
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

variable "kms_arn" {
  description = "kms key arn for eks cluster encryption... Need to pass if create_kms_key set false"
  type = string
  default = false
}

variable "create_kms_key" {
  description="Controls if a KMS key for cluster encryption should be created"
  type = bool
  default = false
}

variable "allow_https_cidr_blocks" {
  description = "Allow https cidr blocks"
  type = list(string)
  default = ["10.40.0.0/24"]
}

variable "cluster_region" {
  description = "cluster region"
  type = string
}


# EKS Managed Node Group
variable "eks managed node groups" {
  description = "Map of EKS managed node group definitions to create"
  type = any
  default = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type = any
  default = {}
}

# aws-auth configmap

variable "manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type = bool
  default = true
}

variable "access_entries" {
  description = "List of role maps to ass to the aws-auth configmap"
  type = any
  default = null
}

#common

variable "environment" {
  description = "Enviornment name"
  type = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type = string
  default = null
}

