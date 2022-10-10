output "multibox_url" {
  value = "http://${docker_container.nginx.name}:${local.port}"
}
output "multibox_url_external" {
  value = "http://localhost:${local.host_port}"
}
