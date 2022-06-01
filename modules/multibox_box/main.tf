/// Configures a box within a multibox instance.
/// Configures not only the box, but 
///  - token introspection, to allow externally authenticated users to access
///  - access policies, deciding what externally authenticated users can do based on their roles

resource "aidbox_box" "box" {
  name         = var.box_id
  fhir_version = var.fhir_version
  description  = var.box_description
}

// Client representing the box itself.
// This is currently used for holding box-specific roles
// Later it might also be used for proper OpenID authentication to the box UI
resource "keycloak_openid_client" "client" {
  realm_id    = var.keycloak_realm
  client_id   = "${var.box_id}-client"
  name        = "${var.box_id}-client"
  enabled     = true
  access_type = "BEARER-ONLY"
}

// https://docs.aidbox.app/security-and-access-control-1/auth/access-token-introspection
resource "aidbox_token_introspector" "token_introspector" {
  box_id = aidbox_box.box.name
  type     = "jwt"
  jwks_uri = var.jwks_url
  jwt {
    iss = var.jwt_issuer
  }
}

// Configure 3 policies for 3 different roles:
// fhir_reader can read arbitrary FHIR resources
// fhir_writer can read & write & delete arbitrary FHIR resources
// sql_exec can use the /sql endpoint to execute arbitrary SQL
// https://docs.aidbox.app/security-and-access-control-1/security/access-control#request-object-structure

resource "keycloak_role" "fhir_reader" {
  realm_id  = var.keycloak_realm
  client_id = keycloak_openid_client.client.id
  name      = "fhir_reader"
}

resource "aidbox_access_policy" "fhir_reader" {
  box_id = aidbox_box.box.name
  description = "fhir_reader role can read FHIR resources"
  engine      = "json-schema"
  schema      = jsonencode({
    "required"   = ["jwt", "uri", "request-method"]
    "properties" = {
      "uri" = {
        "type"    = "string"
        "pattern" = "^/fhir/.*"
      }
      "request-method" = {
        "type"     = "string"
        "constant" = "get"
      }
      "jwt" = {
        "type"       = "object"
        "required"   = ["iss", "resource_access"]
        "properties" = {
          "iss" = {
            "constant" = var.jwt_issuer
          }
          "resource_access" = {
            "type"       = "object"
            "required"   = [keycloak_openid_client.client.name]
            "properties" = {
              (keycloak_openid_client.client.name) = {
                "type"       = "object"
                "required"   = ["roles"]
                "properties" = {
                  "roles" = {
                    "type"     = "array"
                    "contains" = {
                      "type"     = "string"
                      "constant" = keycloak_role.fhir_reader.name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })
}

resource "keycloak_role" "fhir_writer" {
  realm_id  = var.keycloak_realm
  client_id = keycloak_openid_client.client.id
  name      = "fhir_writer"
}
resource "aidbox_access_policy" "fhir_writer" {
  box_id = aidbox_box.box.name
  description = "fhir_writer role can read FHIR resources"
  engine      = "json-schema"
  schema      = jsonencode({
    "required"   = ["jwt", "uri"]
    "properties" = {
      "uri" = {
        "type"    = "string"
        "pattern" = "^/fhir/.*"
      }
      "jwt" = {
        "type"       = "object"
        "required"   = ["iss", "resource_access"]
        "properties" = {
          "iss" = {
            "constant" = var.jwt_issuer
          }
          "resource_access" = {
            "type"       = "object"
            "required"   = [keycloak_openid_client.client.name]
            "properties" = {
              (keycloak_openid_client.client.name) = {
                "type"       = "object"
                "required"   = ["roles"]
                "properties" = {
                  "roles" = {
                    "type"     = "array"
                    "contains" = {
                      "type"     = "string"
                      "constant" = keycloak_role.fhir_writer.name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })
}

resource "keycloak_role" "sql_exec" {
  realm_id  = var.keycloak_realm
  client_id = keycloak_openid_client.client.id
  name      = "sql_exec"
}
resource "aidbox_access_policy" "sql_exec" {
  box_id = aidbox_box.box.name
  description = "sql_exec can execute arbitrary SQL"
  engine      = "json-schema"
  schema      = jsonencode({
    "required"   = ["jwt", "uri"]
    "properties" = {
      "uri" = {
        "type"    = "string"
        // Literal $ to indicate a FHIR operation, collides with regex syntax
        "pattern" = "^/[$]sql$"
      }
      "jwt" = {
        "type"       = "object"
        "required"   = ["iss", "resource_access"]
        "properties" = {
          "iss" = {
            "constant" = var.jwt_issuer
          }
          "resource_access" = {
            "type"       = "object"
            "required"   = [keycloak_openid_client.client.name]
            "properties" = {
              (keycloak_openid_client.client.name) = {
                "type"       = "object"
                "required"   = ["roles"]
                "properties" = {
                  "roles" = {
                    "type"     = "array"
                    "contains" = {
                      "type"     = "string"
                      "constant" = keycloak_role.sql_exec.name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })
}