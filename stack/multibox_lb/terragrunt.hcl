include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_name = "mock_network"
  }
}

dependency "multibox" {
  config_path = "../multibox"
  mock_outputs = {
    multibox_container_port  = "mock_multibox_container_port"
    multibox_container_names = "mock_multibox_container_names"
  }
}

inputs = {
  network_name             = dependency.network.outputs.network_name
  multibox_container_port  = dependency.multibox.outputs.multibox_container_port
  multibox_container_names = dependency.multibox.outputs.multibox_container_names
}
