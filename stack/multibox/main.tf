locals {
  port = 8080
  metrics_port = 8888
  db_port           = 5432
  db_host_port      = 5437
  admin_user_id     = "admin"
  admin_user_secret = "admin"
  containers    = {
    "multibox-1" = {
      "host_port" = 8083
    } 
    "multibox-2" = {
      "host_port" = 8084
    }
  }
  domain_name     =     "multibox"
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
  # Run two instances, we'll load balance them.
  for_each = local.containers
  # Version pinned 2022-09-14 tag healthsamurai/multibox:edge
  #image = "healthsamurai/multibox@sha256:d00756de29731b609e5df70efcd07f03b3da5158152b11bb2fc37c85a56fb00e"
  image = "healthsamurai/multibox@sha256:a621c50812578434d0d3af29733da9687ac053699c3a770bfad9b81e993dcc87"
  name  = each.key
  networks_advanced {
    name    = var.network_name
  }

  env = [
    "AIDBOX_LICENSE=${var.multibox_license}",
    "AIDBOX_PORT=${local.port}",
    "AIDBOX_CLUSTER_SECRET=cluster_secret",
    "AIDBOX_CLUSTER_DOMAIN=${local.domain_name}",
    "AIDBOX_BASE_URL=http://${local.domain_name}:${local.port}",
    "AIDBOX_SUPERUSER=${local.admin_user_id}:${local.admin_user_secret}",
    "PGHOST=${docker_container.multibox_db.name}",
    "PGPORT=5432",
    "PGDATABASE=postgres",
    "PGUSER=postgres",
    "PGPASSWORD=postgres",
    "AIDBOX_STDOUT_JSON=info",
    "BOX_METRICS_PORT=${local.metrics_port}",
    "LOGS_FILTER=select(.ev == \"w/resp\")"
  ]

  ports {
    internal = local.port
    external = each.value.host_port
    ip       = "127.0.0.1"
  }

  # 2Gi
  memory = 2048

  provisioner "local-exec" {
    command = "timeout 1200 sh -c 'until curl -f http://localhost:${each.value.host_port}; do sleep 1; done'"
  }
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}