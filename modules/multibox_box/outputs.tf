output "box_url" {
  value = aidbox_box.box.box_url
}
output "client_id" {
  value = keycloak_openid_client.client.id
}
output "reader_role_name" {
  value = keycloak_role.fhir_reader.name
}
output "writer_role_name" {
  value = keycloak_role.fhir_writer.name
}
output "sql_exec_role_name" {
  value = keycloak_role.sql_exec.name
}