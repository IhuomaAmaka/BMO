data "aws_secretsmanager_secret" "postgres_secret" {
  count                 = var.multi_az ? 0 : 1
  arn = one(module.rds_postgres[*].cluster_master_user_secret)[0].secret_arn
 
 depends_on = [
    module.rds_postgres
  ]
}

data "aws_secretsmanager_secret_version" "secret_version" {
  count                        = var.multi_az ? 0 : 1
  secret_id = one(data.aws_secretsmanager_secret.postgres_secret[*].id)
  
  depends_on = [
    module.rds_postgres,
    data.aws_secretsmanager_secret.postgres_secret
  ]
}

data "aws_secretsmanager_secret" "postgres_secret_multi_az" {
  count = var.multi_az ? 1 : 0
  arn = one(module.rds_postgres[*].cluster_master_user_secret)[0].secret_arn
  
  depends_on = [
    module.rds_postgres
  ]
}

data "aws_secretsmanager_secret_version" "secret_version_multi_az" {
  count = var.multi_az ? 1 : 0
  secret_id = one(data.aws_secretsmanager_secret.postgres_secret_multi_az[*].id)

  depends_on= [
    module.rds_postgres_multi_az,
    data.aws_secretsmanager_secret.postgres_secret_multi_az
  ]
}

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.remote_vpc_id

  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks
 
  tags        = var.tags
}

module "subnet_group" {
  source  = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
  version = "6.1.0"
  
  name    = var.subnet_group_name
  use_name_prefix = var.subnet_group_use_name_prefix
  description     = var.subnet_group_description
  subnet_ids      = var.subnet_ids

  tags = var.tags
}

module "rds_postgres" {
  source                         = "terraform-aws-modules/rds-aurora/aws"
  version                        = "8.5.0"
  count                          = var.multi_az ? 0 : 1
  name                           = var.identifier
  engine                         = var.engine # "aurora-postgresql"
  engine_version                 = var.engine_version
  instance_class                 = var.instance_class
  instances                      = { 1 = {} } # auto scaling # Description: Map of cluster instances and any specific/overriding attributes to be created
  master_username                = var.username
  manage_master_user_password    = true

  vpc_id                         = var.remote_vpc_id
  db_subnet_group_name           = module.subnet_group.db_subnet_group_id
  port                           = var.port
  vpc_security_group_ids         = [module.rds_security_group.security_group_id] # ??
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks                = var.allowed_ingress_cidr_blocks
    }
  }
  autoscaling_enabled            = var.autoscaling_enabled
  autoscaling_min_capacity       = var.autoscaling_min_capacity
  autoscaling_max_capacity       = var.autosaling_max_capacity

  monitoring_interval            = 60
  iam_role_name                  = var.monitoring_role_name
  iam_role_use_name_prefix       = true
  iam_role_description           = var.monitoring_role_description
  iam_role_path                  = "/autoscaling/"
  iam_role_max_session_duration  = 7200

  apply_immediately               = false
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  create_db_cluster_parameter_group      = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_description = var.db_cluster_parameter_group_description
  db_cluster_parameter_group_family      = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_name        = var.db_c1var.db_cluster_parameter_group_name
  db_cluster_parameter_group_parameters  = var.db_cluster_parameter_group_parameters

  snapshot_identifier                    = var.snapshot_identifier
  copy_tags_to_snapshot                  = var.copy_var.copy_tags_to_snapshot
  
  create_cloudwatch_log_group            = true
  allow_major_version_upgrade            = var.allow_major_version_upgrade
  auto_minor_version_upgrade             = var.auto_minor_version_upgrade
  performance_insights_enabled           = var.performance_insights_enabled
  performance_insights_retention_period  = var.performance_insights_retention_period
  create_monitoring_role                 = true
  deletion protection                    = false
  backup_retention_period                = var.backup_retention_period
  preferred_maintenance_window           = var.maintenance_window
  preferred_backup_window                = var.backup_window

  tags = var.tags
}

module "rds_postgres_multi_az" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "8.5.0"
  count   = var.multi_az ? 1 : 0

  name                        = var.identifier
  engine                      = var.engine # "aurora-postgresq1"
  engine_version              = var.engine_version
  # instance_class              = var.instance_class
  instances                   = { 1 = {} } # auto scaling # Description: Map of cluster instances and any specific/overriding attributes to be created
  master_username             = var.username
  manage_master_user_password = true

  vpc_id                      = var.remote_vpc_id
  db_subnet_group_name        = module.subnet group.db_subnet_group_id
  port                        = var.port
  vpc_security_group_ids      = [module.rds_security_group.security_group_id] # ??
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks             = var.allowed_ingress_cidr_blocks
    }
  }
  autoscaling_enabled         = var.autoscaling_enabled
  autoscaling_min_capacity    = var.autoscaling_min_capacity
  autoscaling_max_capacity    = var.autoscaling_max_capacity

  availability_zones          = var.availability_zones
  allocated_storage           = var.allocated_storage
  db_cluster_instance_class   = var.instance_class 
  iops                        = var.iops 
  storage_type                = var.storage_type # "io1"

  monitoring_interval         = 60
  iam_role_name               = var.monitoring_role_name
  iam_role_use_name_prefix    = true
  iam_role_description        = var.monitoring_role_description
  iam_role_path               = "/autoscaling/"
  iam_role_max_session_duration  = 7200

  apply_immediately           = false
  skip_final_snapshot         = true

  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports

  create_cloudwatch_log_group           = true
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  create_monitoring_role                = true
  deletion_protection                   = false
  backup_retention_period               = var.backup_retention_period
  preferred_maintenance_window          = var.maintenance_window
  preferred_backup_window               = var.backup_window

  tags = var.tags
}

module "postgres_secretarn_ssm" {
  source               = "terraform-aws-modules/ssm-parameter/aws"
  count                = var.multi_az ? 0 : 1
  version              = "1.1.0"

  name                 = var.postgres_secretarn_ssm_name
  type                 = "SecureString"
  secure_type          = true
  description          = "postgres endpoint for ${var.postgres_secretarn_ssm_name}"
  tier                 = "Advanced"
  value                = one(aws_secretsmanager_secret.postgres_secret[*].arn)

  depends_on = [
    aws_secretsmanager_secret.postgres_secret
  ]

  tags         = var.tags
}

module "postgres_endpoint_ssm" {
  source               = "terraform-aws-modules/ssm-parameter/aws"
  count                = var.multi_az ? 0 : 1
  version              = "1.1.0"

  name                 = var.postgres_endpoint_ssm_name
  type                 = "SecureString"
  secure_type          = true
  description          = "postgres endpoint for ${var.postgres_endpoint_ssm_name}"
  tier                 = "Advanced"
  value                = one(module.rds_postgres[*].cluster_endpoint)
  tags                 = var.tags
}

module "postgres_secretarn_ssm_multi_az" {
  source               = "terraform-aws-modules/ssm-parameter/aws"
  count                = var.multi_az ? 1 : 0
  version              = "1.1.0"

  name                 = var.postgres_secretarn_ssm_name
  type                 = "SecureString"
  secure_type          = true
  description          = "postgres endpoint for ${var.postgres_secretarn_ssm_name}"
  tier                 = "Advanced"
  value                = one(module_postgres_multi_az[*].cluster_master_user_secret)[0].secret_arn

  tags                 = var.tags
}

module "postgres_endpoint_ssm_multi_az" {
  source               = "terraform-aws-modules/ssm-parameter/aws"
  count                = var.multi_az ? 1 : 0
  version              = "1.1.0"

  name                 = var.postgres_endpoint_ssm_name
  type                 = "SecureString"
  secure_type          = true
  description          = "postgres endpoint for ${var.postgres_endpoint_ssm_name}"
  tier                 = "Advanced"
  value                = one(module.rds_postgres_multi_az[*].cluster_endpoint) #Writer endpoint for the cluster
  tags                 = var.tags
}

resource "aws_secretsmanager_secret" "postgres_secret" {
  count           = var.multi_az ? 0 : 1
  name            = "${var.identifier}-secrets"
  description     = "Secret for RDS name ${var.identifier}"
  depends_on = [
    data.aws_secretsmanager_secret_version.secret_version,
    module.rds_postgres
  ]

  tags          = var.tags
}

resource "aws_secretsmanager_secret_version" "credentials" {
  count                      = var.multi_az ? 0 : 1
  secret_id = one(aws_secretsmanager_secret.postgres_secret[*].id)
  
  secret_string = jsonencode(merge(
      {host="${one(module.rds_postgres[*].cluster_endpoint)}"},
      {username="${jsondecode(nonsensitive(one(data.aws_secretsmanager_secret_version.secret_version[*]).secret_string))["username"]}"},
      {password="${jsondecode(nonsensitive(one(data.aws_secretsmanager_secret_version.secret_version[*]).secret_string))["password"]}"}
  ))

  depends_on = [
    data.aws_secretsmanager_secret_version.secret_version,
    module.rds_postgres
  ]
}

resource "aws_secretsmanager_secret" "postgres_secret_multi_az" {
  count           = var.multi_az ? 1 : 0
  name            = "${var.identifier}-secrets-multiaz"
  description     = "Secret for multi az RDS name ${var.identifier}"
  depends_on = [
    data.aws_secretsmanager_secret_version.secret_version_multi_az,
    module.rds_postgres_multi_az
  ]

  tags          = var.tags
}

resource "aws_secretsmanager_secret_version" "credentials_multi_az" {
  count                      = var.multi_az ? 1 : 0
  secret_id = one(aws_secretsmanager_secret.postgres_secret_multi_az[*].id)
  
  secret_string = jsonencode(merge(
      {host="${one(module.rds_postgres_multi_az[*].cluster_endpoint)}"},
      {username="${jsondecode(nonsensitive(one(data.aws_secretsmanager_secret_version.secret_version_multi_az[*]).secret_string))["username"]}"},
      {password="${jsondecode(nonsensitive(one(data.aws_secretsmanager_secret_version.secret_version_multi_az[*]).secret_string))["password"]}"}
  ))

  depends_on = [
    data.aws_secretsmanager_secret_version.secret_version_multi_az,
    module.rds_postgres_multi_az
  ]
}







  





