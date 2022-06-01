resource "keycloak_realm" "pkb" {
  realm                = "pkb"
  enabled              = true
  display_name         = "PKB"
  display_name_html    = "<b>PKB</b>"
  login_theme          = "base"
  access_code_lifespan = "1h"
  ssl_required         = "external"
}
