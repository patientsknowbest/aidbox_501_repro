terraform {
  required_version = ">=1.0.0, <2.0.0"
  required_providers {
    aidbox = {
      source  = "patientsknowbest/aidbox"
      version = "0.10.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.6.0"
    }
  }
}