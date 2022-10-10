include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {

    network_name = "mock_network_name"
  }
}

dependency "multibox_config" {
  config_path = "../multibox_config"
  mock_outputs = {
    aidbox_aggregate_url = "mock_aidbox_aggregate_url"
    aggregator_client_id = "mock_aggregator_client_id"
    aggregator_client_secret = "mock_aggregator_client_secret"
  }
}

dependency "keycloak"  {
  config_path = "../keycloak"
  mock_outputs = {
    keycloak_url = "mock_keycloak_url"
  }
}
inputs = {
  network_name         = dependency.network.outputs.network_name
  aidbox_aggregate_url = dependency.multibox_config.outputs.aidbox_aggregate_url
  aggregator_client_id = dependency.multibox_config.outputs.aggregator_client_id
  aggregator_client_secret = dependency.multibox_config.outputs.aggregator_client_secret
  keycloak_url = dependency.keycloak.outputs.keycloak_url
}
