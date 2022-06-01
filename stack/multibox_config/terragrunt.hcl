include "root" {
  path = find_in_parent_folders()
}

dependency "multibox" {
  config_path  = "../multibox"
  mock_outputs = {
    multibox_url_external        = "mock_multibox_url_external"
    multibox_admin_client_id     = "mock_multibox_admin_client_id"
    multibox_admin_client_secret = "mock_multibox_admin_client_secret"
    multibox_container_name      = "mock_multibox_container_name"
  }
}

dependency "keycloak_config" {
  config_path  = "../keycloak_config"
  mock_outputs = {
    keycloak_jwks_uri     = "mock_jwks_uri"
    keycloak_jwt_issuer   = "mock_jwt_issuer"
    keycloak_pkb_realm_id = "mock_keycloak_pkb_realm_id"
  }
}

dependency "keycloak" {
  config_path  = "../keycloak"
  mock_outputs = {
    keycloak_url_external = "mock_keycloak_url_external"
    keycloak_username     = "mock_keycloak_username"
    keycloak_password     = "mock_keycloak_password"
  }
}

inputs = {
  multibox_url_external        = dependency.multibox.outputs.multibox_url_external
  multibox_admin_client_id     = dependency.multibox.outputs.multibox_admin_client_id
  multibox_admin_client_secret = dependency.multibox.outputs.multibox_admin_client_secret
  multibox_container_name      = dependency.multibox.outputs.multibox_container_name

  keycloak_jwks_uri     = dependency.keycloak_config.outputs.keycloak_jwks_uri
  keycloak_jwt_issuer   = dependency.keycloak_config.outputs.keycloak_jwt_issuer
  keycloak_pkb_realm_id = dependency.keycloak_config.outputs.keycloak_pkb_realm_id

  keycloak_url_external = dependency.keycloak.outputs.keycloak_url_external
  keycloak_username     = dependency.keycloak.outputs.keycloak_username
  keycloak_password     = dependency.keycloak.outputs.keycloak_password
}