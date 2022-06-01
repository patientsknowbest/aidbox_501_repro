locals {
  port              = 8080
  host_port         = 8080
  db_port           = 5432
  db_host_port      = 5437
  admin_user_id     = "admin"
  admin_user_secret = "admin"
  container_name    = "multibox.localhost"
}

resource "docker_container" "multibox_db" {
  image = "healthsamurai/aidboxdb:14.2"
  name  = "multibox-db"
  networks_advanced {
    name    = var.network_name
  }
  ports {
    internal = local.db_port
    external = local.db_host_port
    ip       = "127.0.0.1"
  }
  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_DB=postgres"
  ]
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}

// Multibox, multi-tenant FHIR server
resource "docker_container" "multibox" {
  # Version pinned 2022-05-29 tag healthsamurai/multibox:2202-lts
  image = "healthsamurai/multibox@sha256:b621a02f9eb6820b59dd19d43e8b61952f82eba30f2b14166e1789982e9e14fe"
  name  = local.container_name
  networks_advanced {
    name    = var.network_name
    aliases = [
      // Workaround, while docker network doesn't support wildcard aliases.
      // https://github.com/moby/moby/pull/43444
      "customer1.${local.container_name}",
      "phrmigrated.${local.container_name}",
      "aggregate.${local.container_name}",
    ]
  }
  ports {
    internal = local.port
    external = local.host_port
    ip       = "127.0.0.1"
  }

  env = [
    "AIDBOX_LICENSE=${var.multibox_license}",
    "AIDBOX_PORT=${local.port}",
    "AIDBOX_CLUSTER_SECRET=cluster_secret",
    "AIDBOX_CLUSTER_DOMAIN=${local.container_name}",
    "AIDBOX_BASE_URL=http://${local.container_name}:${local.port}",
    "AIDBOX_SUPERUSER=${local.admin_user_id}:${local.admin_user_secret}",
    "PGHOST=${docker_container.multibox_db.name}",
    "PGPORT=5432",
    "PGDATABASE=postgres",
    "PGUSER=postgres",
    "PGPASSWORD=postgres",
    "JAVA_OPTS=-Xms64m -Xmx256M",
    "AIDBOX_DEV_MODE=1"
  ]
  provisioner "local-exec" {
    command = "timeout 1200 sh -c 'until curl -f http://localhost:${local.host_port}; do sleep 1; done'"
  }
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}