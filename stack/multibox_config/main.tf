// Configure aidbox to validate tokens from keycloak
// Configure resource servers & clients in keycloak. Note that we configure resource servers as clients also, 
// in order that users can be assigned client-specific roles. This lets us configure e.g. customer_1 service account 
// can _only_ access aidbox for customer 1, without excessive coupling between aidbox access policies and specific 
// users / roles.

// Use a module to deploy boxes within multibox
// pre-configured with external access policies
/// IMPORTANT: see note in pkb-end2end/ui-tests/terraform/stack/multibox/main.tf regarding hostnames for these boxes.
/// While we are in plain docker, wildcard aliases aren't supported so each box has to be added to the list of aliases
/// for the multibox container. Sad.
locals {
  boxes = {
    customer1 = {
      box_description = "Box for customer 1's data"
      fhir_version    = "fhir-3.0.1"
    }
    phrmigrated = {
      box_description = "Box for migrated PHR data"
      fhir_version    = "fhir-4.0.1"
    }
    aggregate = {
      box_description = "Box for aggregated data"
      fhir_version    = "fhir-4.0.1"
    }
  }
}
module "boxes" {
  for_each        = local.boxes
  source          = "../../modules/multibox_box"
  box_id          = each.key
  box_description = each.value.box_description
  fhir_version    = each.value.fhir_version
  jwks_url        = var.keycloak_jwks_uri
  jwt_issuer      = var.keycloak_jwt_issuer
  keycloak_realm  = var.keycloak_pkb_realm_id
}

// Clients/service-accounts which will access box instances.
// Both PKB internal services (e.g. aggregator) and customers (e.g. cust-1) 
// are represented here
locals {
  clients = [
    "cust-1",
    "aggregator",
    "ehrmigrator",
    "fhirwall"
  ]
}
resource "keycloak_openid_client" "clients" {
  for_each                     = toset(local.clients)
  realm_id                     = var.keycloak_pkb_realm_id
  client_id                    = each.value
  name                         = each.value
  enabled                      = true
  direct_access_grants_enabled = true
  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
}

// Clients have different permissions (read, write, exec arbitrary SQL) on each box.
locals {
  role_assignments = [
    {
      client = "cust-1"
      box    = "customer1"
      role   = "fhir_writer"
    },
    {
      client = "aggregator"
      box    = "aggregate"
      role   = "fhir_writer"
    },
    {
      client = "aggregator"
      box    = "aggregate"
      role   = "sql_exec"
    },
    {
      client = "aggregator"
      box    = "customer1"
      role   = "fhir_reader"
    },
    {
      client = "aggregator"
      box    = "phrmigrated"
      role   = "fhir_reader"
    },
    {
      client = "ehrmigrator"
      box    = "phrmigrated"
      role   = "fhir_writer"
    },
    {
      client = "fhirwall"
      box    = "aggregate"
      role   = "fhir_reader"
    },
  ]
}
resource "keycloak_openid_client_service_account_role" "sa_role_assignments" {
  // for_each expects a map. There is no natural key for assignment of role to client,
  // so make one up: use a hash of the attributes.
  for_each = tomap({
    for item in flatten([
      for ra in local.role_assignments : {
        name  = md5(jsonencode(ra))
        value = ra
      }
    ]) : item.name => item.value
  })
  realm_id                = var.keycloak_pkb_realm_id
  service_account_user_id = keycloak_openid_client.clients[each.value.client].service_account_user_id
  client_id               = module.boxes[each.value.box].client_id
  role                    = each.value.role
}

// TODO: MFA - here was the workaround
// Multibox has a caching bug, it doesn't recognise TokenIntrospectors until it's rebooted
// https://github.com/Aidbox/Issues/issues/501
#resource "null_resource" "provisioner_restart_mbox" {
#  provisioner "local-exec" {
#    command = "docker restart ${var.multibox_container_name} && timeout 1200 sh -c 'until curl -f ${var.multibox_url_external}; do sleep 1; done'"
#  }
#  depends_on = [module.boxes]
#}
