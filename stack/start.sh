#!/usr/bin/env bash

# Get license key from gcloud secrets, unless it's preset in the environment
MB_LICENSE=${MB_LICENSE:-}
if [ "${MB_LICENSE}" == "" ]; then
  echo "You must supply MB_LICENSE environment variable with multibox license key"
  exit 1
fi
TF_VAR_multibox_license=${MB_LICENSE} \
terragrunt \
  run-all apply \
  --terragrunt-non-interactive
