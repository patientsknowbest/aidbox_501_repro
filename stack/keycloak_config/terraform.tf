terraform {
  required_version = ">=1.0.0, <2.0.0"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.6.0"
    }
  }
  backend "local" { /*terragrunt will provide this*/ }
}