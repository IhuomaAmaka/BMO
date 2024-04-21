# Global
variable "tags {
  type = map(string)
  description = "A map of tags"
}

variable "remote_vpc_id" {
  type = string
  description = "VPC id from remote state"
}

# subnet group
variable "subnet_group_name" {
  type = string
  description = "subnet group Name"
}

variable "subnet_group_use_name_prefix" {
  type = bool
  description = "Determines whether to use `name'as is or create a unique name beginning with "name" as the specified prefix"
  default = true
}

variable "subnet_group_description" {
  type = string
  description = "Subnet group Description"
}

variable "subnet_ids" {
  type = list(string)
  description = "List subnet id's from remote state"
}
#####
# rds postgres
variable "engine" {
  type = string
  description = "RDS engine"
}

variable "monitoring_role_name" {
  type = string
  description = "rds monitoring role name"
}

variable "monitoring_role_description" {
  type = string
  description = "rds monitoring role description"
}

variable "engine_version" {
  type = string
  description = "rds engine version"
}

variable "identifier" {
  type = string
  description= "rds identifier"
}

variable “family" {
  type = string
  description = "rds engine family"
}

variable "major_engine_version" {
  type = string
  description = "rds major engine version"
}

variable "maintenance_window" {
  type = string
  description = "rds maintenance window"
}

variable "instance_class" {
  type = string
  description = "rds instance class"
  default = "db.r6g.large"
}

variable "port" {
  type = number
  description = "rds port number"
  default= 5432
}

variable "db_name" {
  type = string
  description = "rds db name"
}

variable "username” {
  type = string
  description = "rds usr name"
}

variable "backup_window" {
  type = string
  description = "rds backup window"
  default = "sun:00:00-sun:01:00"
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
  description = "rds cloudwatch logs exports"
  default = ["postgresql", "upgrade"]
}

variable "allow_major_version_upgrade" {
  type = bool
  description = "rds enable major version upgrade"
  default = false
}

variable "auto_minor_version_upgrade" {
  type = bool
  description = "rds enable minor version upgrade"
  default = false
}

variable "backup_retention_period" {
  type = number
  description = "rds db name"
  default = 7
}

variable "performance_insights_enabled" {
  type = bool
  description = "rds enable performance insights"
  default = true
}
variable "performance_insights_retention_period" {
  type = number
  description = "rds performance insights retention period"
  default = 7
}

variable "allocated_storage" {
  type = number
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB Cluster (REQUIRED)
  default = 20
}

variable "max_allocated_storage" {
  type = number
  description = "rds max allocated storage”
  default = 100
}

variable "multi_az” {
  type = bool
  description = "rds enable multi_az"
  default = true
} 

variable "storage_type" {
  type = string
  description = "Storage type to use for multi az cluster"
  default = null
}

variable "iops" {
  type = number
  description = "iops for multi az cluster"
  default = null
}

variable "availability_zones" {
  type = list(string)
  description = "availability_zones for multi az cluster"
}

variable "create_db_cluster_parameter_group" {
  type = bool
  default = false
  description = "Determines whether a cluster parameter should be created or use existing"
}

variable "db_cluster_parameter_group_description" {
  type= string
  default = null
  description = "The description of the DB cluster parameter group. Defaults to \"Managed by Terraform"\
}

variable "db_cluster_parameter_group_family" {
  type = string
  default = ""
  description = "The family of the DB cluster parameter group"
}

variable "db_cluster_parameter_group_name" {
  type = string
  default = null
  description = "The name of the DB parameter group"
}

variable "db_cluster_parameter_group_parameters" {
  type = list(map(string))
  default =[]
  description = "DB Cluster Parameter Group Parameters"
}

variable "snapshot_identifier" {
  type = string
  default = null
  description = "Specifies whether or not to create this cluster from a snapshot."
}

variable "copy_tags_to_snapshot"{
  type = bool
  default = true
  description = "Specifies whether or not to copy,the rds tags to every snapshot created"
}

# security group
variable "security_group_name" {
  type = string
  description = "A name for security group"
}

variable "security_group_description" {
  type = string
  description = "A Description for security group"
}

variable "ingress_with_cidr_blocks" {
  type = list(map(string))
  description = "list of ingress cidr blocks"
}

variable "egress_with_cidr_blocks" {
  type = list(map(string))
  description = "list of egress cidr blocks"
}

variable "allowed_ingress_cidr_blocks"{
  type = list(string)
  description = "List subnet id's cidr blocks"
}

variable "autoscaling_min_capacity" {
  type = number
  default = 1
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
}

variable "autoscaling_max_capacity" {
  type = number
  default = 5
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
}

variable "autoscaling_enabled" {
  type = bool
  default = false
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
}

# ssm
variable "postgres_secretarn_ssm_name" {
  type = string
  description = "postgres secretar ssm path name"
}

variable "postgres_endpoint_ssm_name" {
  type = string
  description = "postgres endpoint ssm path name"
}





