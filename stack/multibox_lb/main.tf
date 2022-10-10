locals {
  port              = 8080
  host_port         = 8080
  config_file_path = "${path.module}/nginx.conf"
}
resource "docker_container" "nginx" {
  name = "multibox-lb"
  image = "nginx"
  networks_advanced {
    name    = var.network_name
    aliases = [
      // Workaround, while docker network doesn't support wildcard aliases.
      // https://github.com/moby/moby/pull/43444
      "customer1.multibox",
      "phrmigrated.multibox",
      "aggregate.multibox",
    ]
  }
  mounts {
    target = "/etc/nginx/nginx.conf"
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
  content = <<EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;

    upstream multibox {
      %{ for addr in var.multibox_container_names ~}
      server ${addr}:${var.multibox_container_port};
      %{ endfor ~}
    }

    server {
      listen ${local.port} default_server;
      server_name _;
      location / {
        proxy_pass http://multibox/;
        proxy_set_header Host            $host;
        proxy_set_header X-Forwarded-For $remote_addr;
      }
    }
}
EOF
  filename = local.config_file_path
}

