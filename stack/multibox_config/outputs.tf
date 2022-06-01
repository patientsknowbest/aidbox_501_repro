/// Note that we don't provide externally accessible URLs for these.
/// That's because multibox does routing based on Host header, so you
/// can't directly access these boxes from outside the cluster without
/// manipulating the Host header.
output "aidbox_customer_1_url" {
  value = module.boxes["customer1"].box_url
}
output "aidbox_phr_migrated_url" {
  value = module.boxes["phrmigrated"].box_url
}
output "aidbox_aggregate_url" {
  value = module.boxes["aggregate"].box_url
}

output "customer_1_client_id" {
  value = keycloak_openid_client.clients["cust-1"].client_id
}
output "customer_1_client_secret" {
  value     = keycloak_openid_client.clients["cust-1"].client_secret
  sensitive = true
}

output "ehrmigrator_client_id" {
  value = keycloak_openid_client.clients["ehrmigrator"].client_id
}
output "ehrmigrator_client_secret" {
  value     = keycloak_openid_client.clients["ehrmigrator"].client_secret
  sensitive = true
}

output "aggregator_client_id" {
  value = keycloak_openid_client.clients["aggregator"].client_id
}
output "aggregator_client_secret" {
  value     = keycloak_openid_client.clients["aggregator"].client_secret
  sensitive = true
}

output "fhirwall_client_id" {
  value = keycloak_openid_client.clients["fhirwall"].client_id
}
output "fhirwall_client_secret" {
  value     = keycloak_openid_client.clients["fhirwall"].client_secret
  sensitive = true
}