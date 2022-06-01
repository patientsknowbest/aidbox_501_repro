variable "box_id" {
  description = "ID of box to create within multibox"
}
variable "fhir_version" {
  description = "Version of FHIR to use on the box"
}
variable "box_description" {
  description = "description of box within multibox"
}

variable "jwt_issuer" {
  description = "Issuer of JWTs that we'll accept. JWTs issued from other endpoints will not be accepted"
}
variable "jwks_url" {
  description = "JSON Web Key Set URL, used for validating JWTs, see https://auth0.com/docs/secure/tokens/json-web-tokens/json-web-key-sets"
}
variable "keycloak_realm" {
  description = "Realm within keycloak to create clients and roles"
}