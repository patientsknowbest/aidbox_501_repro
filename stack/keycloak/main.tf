locals {
  container_name     = "keycloak.localhost"
  keycloak_username  = "admin"
  keycloak_password  = "admin"
  keycloak_port      = 8081
  keycloak_host_port = 8081
}

resource "docker_container" "keycloak" {
  image   = "quay.io/keycloak/keycloak:18.0.0"
  name    = local.container_name
  networks_advanced {
    name = var.network_name
  }
  command = [
    "start-dev",
    "--http-port=${local.keycloak_port}",
    "--http-relative-path=/auth"
  ]
  ports {
    internal = local.keycloak_port
    external = local.keycloak_host_port
    ip       = "127.0.0.1"
  }
  env     = [
    "KEYCLOAK_ADMIN=${local.keycloak_username}",
    "KEYCLOAK_ADMIN_PASSWORD=${local.keycloak_password}",
    replace(<<-EOT
    JAVA_OPTS= 
      -Xms64m 
      -Xmx128m 
      -XX:MetaspaceSize=96M 
      -XX:MaxMetaspaceSize=128m 
      -Djava.net.preferIPv4Stack=true
    EOT
    , "\n", " ")
  ]
  provisioner "local-exec" {
    command = "timeout 1200 sh -c 'until curl -f http://localhost:${local.keycloak_host_port}/auth/; do sleep 1; done'"
  }
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}