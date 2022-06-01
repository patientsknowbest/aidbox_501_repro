provider "aidbox" {
  client_id     = var.multibox_admin_client_id
  client_secret = var.multibox_admin_client_secret
  url           = var.multibox_url_external
  is_multibox = true
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.keycloak_username
  password  = var.keycloak_password
  url       = var.keycloak_url_external
}