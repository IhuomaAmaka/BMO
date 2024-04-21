output "key_arns" {
  value = { for key in keys(var.keys) : replace(key, "aalias/", "") => aws_kms_key.main[key].arn }
}

output "key_ids" {
  value = { for in keys(var.keys) : replace(key, "alias/", "") => aws_kms_key.main[key].key_id }
}
