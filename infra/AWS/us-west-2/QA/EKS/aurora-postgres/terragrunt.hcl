locals {
  # Automatically load environment-level variables
  name             = run_cmd("bash", "-c", "basename $(pwd)")
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
I
  var_config = yamldecode(file("variables.yaml"))
  var_tfvars = yamldecode(file("terraform.tfvars.yaml"))

  # extract from variables.yaml
  sg_ingress_rules                      = local.var_config.config.sg_ingress_rules
  sg_egress_rules                       = local.var_config.config.sg_egress_rules
  port                                  = local.var_config.config.port
  backup_window                         = local.var_config.config.backup_window
  allow_major_version_upgrade           = local.var_config.config.allow_major_version_upgrade
  auto_minor_version_upgrade            = local.var_config.config.auto_minor_version_upgrade
  maintenance_window                    = local.var_config.config.maintenance_window
  allocated_storage                     = local.var_config.config.allocated_storage
  max_allocated_storage                 = local.var_config.config.max_allocated_storage
  multi_az                              = local.var_config.config.multi_az
  instance_class                        = local.var_config.config.instance_class
  engine_version                        = local.var_config.config.engine_version
  engine                                = local.var_config.config.engine
  multi_az_engine                       = local.var_config.config.multi_az_engine
  family                                = local.var_config.config.family
  db_cluster_parameter_group_family     = local.var_config.config.db_cluster_parameter_group_family
  major_engine version                  = local.var_config.config.major_engine_version
  username                              = local.var_config.config.username
  autoscaling_min_capacity              = local.var_config.config.autoscaling_min_capacity
  autoscaling_max_capacity              = local.var_config.config.autoscaling_max_capacity
  autoscaling_enabled                   = local.var_config.config.autoscaling_enabled
  backup_retention_period               = local.var_config.config.backup_retention_period
  performance_insights_enabled          = local.var_config.config.performance_insights_enabled
  performance_insights_retention_period = local.var_config.config.performance_insights_retention_period
  storage_type                          = local.var_config.config.storage_type
  iops                                  = local.var_config.config.iops
  snapshot_identifier                   = local.var_config.config.snapshot_identifier
 
  # Extract out common variables for reuse
  region     = local.var_tfvars.aws_region
  env        = local.var_tfvars.environment
  account_id = local.var_tfvars.account_id

  tags = {
    "Managed-by” : “terraform"
    "Environment" : local.env
    "Service-name": local.name
    "Owner" : "DevOps"
    "Requested-by": "DevOps"
  }
}

terraform {
  source = "../../modules/aurora-postgres"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../network/vpc"]
}

dependency "vpc" {
  config_path = "../network/vpc"
  mock_outputs_allowed_terraform_commands = ["validate"]
  # mock_outputs_allowed_terraform_commands = ["apply","plan","destroy", "output"]
  mock_outputs = {
    vpc_id = "vpc-xxx"
    private_subnets ="subnet-xxxx"
    azs = ["xx-west-2"]
  }
}

inputs = {
  # global
  remote_vpc_id = dependency.vpc.outputs.vpc_id
  name          = "${local.env}-${local.region}-rds-${local.name}"

  # subnet group
  subnet_ids               = dependency.vpc.outputs.private_subnets 
  subnet_group_name        = "${local.env}-${local.region}-rds-${local.name}"
  subnet_group_description = "database subnetfor ${local.region}-rds-${local.name}”
  
  # rds postgres
  availability_zones                    = dependency.vpc.outputs.azs
  monitoring_role_name                  = "${local.env}-${local.region}-${local.name}-monit-role"
  monitoring_role_description           = "${local.env}-${local.region}-${local.name}-monit-role monitoring role"
  engine_version                        = local.engine_version
  engine                                = local.multi_az == true ? local.multi_az_engine : local.engine
  identifier                            = "${local.env}-${local.region}-${local.name}"
  family                                = local.family
  major_engine_version                  = local.major_engine_version
  maintenance_window                    = local.maintenance_window
  instance_class                        = local.instance_class
  port                                  = local.port
  db_name                               = management-db
  username                              = local.username
  backup_window                         = local.backup_window
  enabled_cloudwatch_logs_exports       = local.multi_az == true ? ["postgresql", "upgrade"] : ["postgresql"] 
  allow_major_version_upgrade           = local.allow_major_version_upgrade
  auto_minor_version_upgrade            = local.auto_minor_version_upgrade
  backup_retention_period               = local.backup_retention_period
  performance_insights_enabled          = local.performance_insights_enabled
  performance_insights_retention_period = local.performance_insights_retention period
  allocated_storage                     = local.allocated_storage
  max_allocated_storage                 = local.max_allocated_storage
  multi_az                              = local.multi_az
  allowed_ingress_cidr_blocks           = dependency.vpc.outputs.private_subnets_cidr_ blocks
  autoscaling_min_capacity              = local.autoscaling_min_capacity
  autoscaling_max_capacity              = local.autoscaling_max_capacity
  autoscaling_enabled                   = local.autoscaling_enabled
  #storage_type                         = local.storage_type
  #iops                                 = local.iops


  create_db_cluster_parameter_group     = true
  db_cluster_parameter_group_description = "Parameter group for ${local.env}-${local.region}-rds-${local.name}"
  db_cluster_parameter_group_family     = local.db_cluster_parameter_group_family
  db_cluster_parameter_group_name       = "${local.env}-${local.region}-rds-${local.name}-parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "rds.logical_replication"
      value        = 1
      apply_method = "pending-reboot"
    },
    {
      name  = "session replication_role"
      value = "replica"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pglogical"
      apply_method = "pending-reboot"
    },
    {
      name         = "max_replication_slots"
      value        = 25
      apply_method = "pending-reboots"
    }
  ]
  snapshot_identifier = local.snapshot_identifier
 
  # security group
  security_group_name        = "${local.env}-${local.region}-${local.name}-secgr"
  security_group_description = "${local.env}-${ocal.region}-${local.name} security group"
  ingress_with_cidr_blocks   = local.sg_ingress_rules
  egress_with_cidr_blocks    = local.sg_egress_rules

  # ssm
  postgres_secretarn_ssm_name = “/${local.account_id}/${local.env}/${local.region}/${local.name}/secretarn"
  postgres_endpoint_ssm_name  = "/${local.account_id}/${local.env}/${local.region}/${local.name}/endpoint"

  tags = local.tags
}


