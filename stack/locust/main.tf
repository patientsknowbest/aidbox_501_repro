/*
docker run -p 8089:8089 -v $PWD:/mnt/locust locustio/locust -f /mnt/locust/locustfile.py
*/
locals {
  port              = 8089
  host_port         = 8089
}
resource "docker_container" "nginx" {
  name = "locust"
  image = "locustio/locust"
  command = [
    "-f","/mnt/locust/locustfile.py", 
    "-H", "${var.aidbox_aggregate_url}",
    "--users", "1",
    "--spawn-rate", "1"]
  networks_advanced {
    name    = var.network_name
  }
  mounts {
    target = "/mnt/locust/locustfile.py"
    source = abspath("${path.module}/locustfile.py")
    type   = "bind"
  }
  env = [
  "CLIENT_ID=${var.aggregator_client_id}",
  "CLIENT_SECRET=${var.aggregator_client_secret}",
  "KEYCLOAK_URL=${var.keycloak_url}"
  ]

  ports {
    internal = local.port
    external = local.host_port
    ip       = "127.0.0.1"
  }
}