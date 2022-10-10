terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
  backend "local" { /*terragrunt will provide this*/ }
}