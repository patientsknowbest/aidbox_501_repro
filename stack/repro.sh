#!/usr/bin/env bash
set -e
client_id=$(terragrunt \
  output -raw customer_1_client_id \
  --terragrunt-working-dir=multibox_config)
client_secret=$(terragrunt \
  output -raw customer_1_client_secret \
  --terragrunt-working-dir=multibox_config)
  
# Exchange the client_id and secret for a access token
access_token=$(curl -H "Host: keycloak:8080" http://localhost:8081/auth/realms/pkb/protocol/openid-connect/token -d \
  "grant_type=client_credentials&client_id=${client_id}&client_secret=${client_secret}" \
  | jq -rc '.access_token')

# try to access the FHIR server
customer_1_server=$(terragrunt \
  output -raw aidbox_customer_1_url \
  --terragrunt-working-dir=multibox_config)
  
curl -f -H "Authorization: Bearer ${access_token}" ${customer_1_server}/fhir/Patient \
  && echo "" && echo 'SUCCESS!'

