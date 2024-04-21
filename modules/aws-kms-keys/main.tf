resource "aws_kms_key" "main" {
  for_each                = var.keys
  description             = try(each.value.description, null)
  deletion_window_in_days = try(each.value.deletion_window_in_days, null)
  key_usage               = try(each.value.key_usage, null)
  enable_key_rotation     = try(each.value.enable_key_rotation, true)
  policy                  = try(each.value.policy, null)
  multi_region            = try(each.value.multi_region, null)
  tags                    = try(each.value.tags,{})
}

resource "aws_kms_alias" "main" {
  for_each      = var.keys
  name          = "alias/${each.key}"
  target_key_id = aws_kms_key.main[each.key].key_id
}
