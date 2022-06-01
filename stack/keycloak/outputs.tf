output "keycloak_url" {
  value = "http://${docker_container.keycloak.name}:${local.keycloak_port}"
}
# External URL is for the test-runner to access the application from outside the docker network
output "keycloak_url_external" {
  value = "http://localhost:${local.keycloak_host_port}"
}
output "keycloak_username" {
  value = local.keycloak_username
}
output "keycloak_password" {
  value = local.keycloak_password
}