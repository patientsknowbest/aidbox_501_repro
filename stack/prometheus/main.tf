/*

docker run \
    -p 9090:9090 \
    -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus

docker run -d --name=grafana -p 3000:3000 grafana/grafana
*/
locals {
  port             = 9090
  host_port        = 9090
  config_file_path = "${path.module}/prometheus.yml"
}
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus"
  networks_advanced {
    name = var.network_name
  }
  mounts {
    target = "/etc/prometheus/prometheus.yml"
    source = abspath("${local.config_file_path}")
    type   = "bind"
  }

  ports {
    internal = local.port
    external = local.host_port
    ip       = "127.0.0.1"
  }
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}

resource "local_file" "config_file" {
  content  = <<EOF
global:
  external_labels:
    monitor: 'aidbox'
scrape_configs:
  %{for addr in var.multibox_container_names}
  - job_name: ${addr}
    scrape_interval: 5s
    metrics_path: /metrics
    static_configs:
      - targets: [ '${addr}:${var.multibox_container_metrics_port}' ]
  %{endfor~}
EOF
  filename = local.config_file_path
}
