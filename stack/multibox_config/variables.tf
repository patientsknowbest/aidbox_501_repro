// Expected from multibox variables
variable "multibox_url_external" {
  description = "URL of multibox server on the docker host"
  type = string
}
variable "multibox_admin_client_id" {
  description = "Client ID for accessing multibox API"
  type = string
}
variable "multibox_admin_client_secret" {
  description = "Client secret for accessing multibox API"
  type = string
}

# Expected from keycloak variables.
variable "keycloak_url_external" {
  description = "URL of keycloak server on the docker host"
  type = string
}

variable "keycloak_username" {
  description = "Username for accessing keycloak administration API"
  type = string
}
variable "keycloak_password" {
  description = "Password for accessing keycloak administration API"
  type = string
}

# Expected from keycloak_config outputs
variable "keycloak_jwks_uri" {
  type = string
}

variable "keycloak_jwt_issuer" {
  type = string
}

variable "keycloak_pkb_realm_id" {
  type = string
}

