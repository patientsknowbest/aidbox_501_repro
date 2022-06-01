include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path  = "../network"
  mock_outputs = {
    network_name = "mock_network"
  }
}

inputs = {
  network_name                  = dependency.network.outputs.network_name
}