output "multibox_url" {
  value = "http://${docker_container.multibox.name}:${local.port}"
}
output "multibox_url_external" {
  value = "http://localhost:${local.host_port}"
}
output "multibox_admin_client_id" {
  value = local.admin_user_id
}
output "multibox_admin_client_secret" {
  value = local.admin_user_secret
}
output "multibox_container_name" {
  value = docker_container.multibox.name
}