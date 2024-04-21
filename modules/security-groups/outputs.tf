output "security_group_ids" {
  value = { for sg in module.security_group : sg.security_group_id => sg.security_group_name}
}
