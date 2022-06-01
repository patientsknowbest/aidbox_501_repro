variable "keycloak_url" {
  description = "URL of keycloak server"
  type = string
}

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