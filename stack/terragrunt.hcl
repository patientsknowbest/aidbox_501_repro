# Containers isolated per stack, use separate data and state directories per-stack
locals {
  stack_suffix = get_env("TF_VAR_stack_suffix", "")
}
remote_state {
  backend = "local"
  config = {
    path = local.stack_suffix == "" ? ".state/terraform" : "./.${local.stack_suffix}.state/terraform"
  }
  # https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency
  # You are not relying on before_hook, after_hook, or extra_arguments to the terraform init call. 
  # NOTE: terragrunt will not automatically detect this and you will need to explicitly opt out of the dependency 
  # optimization flag.
  disable_dependency_optimization = true
} 
terraform {
  extra_arguments "stack_workspace" {
    env_vars = {
      TF_DATA_DIR = local.stack_suffix == "" ? ".terraform" : ".${local.stack_suffix}.terraform"
    }
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint",
      "output"
    ]
  }
}

retryable_errors = [
  # These are the defaults, see 
  # https://github.com/gruntwork-io/terragrunt/blob/aa552aa8eaf3a2d2ae20a2898f92ecd1a1bc0967/options/auto_retry_options.go#L10
  "(?s).*Failed to load state.*tcp.*timeout.*",
  "(?s).*Failed to load backend.*TLS handshake timeout.*",
  "(?s).*Creating metric alarm failed.*request to update this alarm is in progress.*",
  "(?s).*Error installing provider.*TLS handshake timeout.*",
  "(?s).*Error configuring the backend.*TLS handshake timeout.*",
  "(?s).*Error installing provider.*tcp.*timeout.*",
  "(?s).*Error installing provider.*tcp.*connection reset by peer.*",
  "NoSuchBucket: The specified bucket does not exist",
  "(?s).*Error creating SSM parameter: TooManyUpdates:.*",
  "(?s).*app.terraform.io.*: 429 Too Many Requests.*",
  "(?s).*ssh_exchange_identification.*Connection closed by remote host.*",
  # This is one we spotted ourselves.
  "(?s).*Client\\.Timeout exceeded while awaiting headers.*",
]
