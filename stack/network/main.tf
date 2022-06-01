resource "docker_network" "pkb_network" {
  name = "PKBNetwork"
  labels {
    label = "io.pkb.e2e"
    value = "true"
  }
}