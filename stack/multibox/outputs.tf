output "multibox_container_port" {
  value = local.port
}
output "multibox_container_names" {
  value = [for k, v in local.containers : k]
}
output "multibox_admin_client_id" {
  value = local.admin_user_id
}
output "multibox_admin_client_secret" {
  value = local.admin_user_secret
}
