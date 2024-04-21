locals{
  security groups = { for security_group in var.security_groups : index(var.security_groups, security_group) => security_group }
}

module "security_group" {
  source  = "terrafoerraform-awsm-aws-mles/security-group/aws"
  version = "4.8.0"
  
  for_each = local.security
  
  name            = each.value.name
  description     = each.value.description
  vpc_id          = each.value.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks              = try(each.value.ingress_with_cidr_blocks, [])
  ingress_with_source_security_group_id = try(each.value.ingress_with_source_security_group_id, [])
  ingress_with_self                     = try(each.value.ingress_with_self, [])
  egress_with_cidr_blocks               = try(each.value.egress_with_cidr_blocks, [])
  egress_with_source_securitty_group_id = try(each.value.egress_with_source_security_group_id, [])
  egress_with_ self                     = try(each.value.egress_with_self, [])
  

  create_timeout = "15m"
  delete_timeout = "45m"
  
  tags = each.value.tags
} 
