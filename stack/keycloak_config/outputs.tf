output "keycloak_jwt_issuer" {
  value = "${var.keycloak_url}/auth/realms/${keycloak_realm.pkb.realm}"
}
output "keycloak_jwks_uri" {
  value = "${var.keycloak_url}/auth/realms/${keycloak_realm.pkb.realm}/protocol/openid-connect/certs"
}
output "keycloak_pkb_realm_id" {
  value = keycloak_realm.pkb.id
}
