include "root" {
  path = find_in_parent_folders()
}

dependency "keycloak" {
  config_path = "../keycloak"
  mock_outputs = {
    keycloak_url          = "mock_keycloak_url"
    keycloak_url_external = "mock_keycloak_url_external"
    keycloak_username     = "mock_keycloak_username"
    keycloak_password     = "mock_keycloak_password"
  }
}

inputs = {
  keycloak_url          = dependency.keycloak.outputs.keycloak_url
  keycloak_url_external = dependency.keycloak.outputs.keycloak_url_external
  keycloak_username     = dependency.keycloak.outputs.keycloak_username
  keycloak_password     = dependency.keycloak.outputs.keycloak_password
}