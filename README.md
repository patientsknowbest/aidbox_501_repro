# Aidbox issue 501 repro

This repository contains a reproduction of this issue: https://github.com/Aidbox/Issues/issues/501

## prerequisites
* linux
* [docker](https://docs.docker.com/engine/install/), and your user must have access to the docker daemon
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) 
* [terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
* Multibox license key, in the environment variable MB_LICENSE

## repro

Boot up the stack 
```bash
cd stack
./start.sh 
```
This creates: 
* keycloak instance
* multibox instance
* boxes within multibox (one of which is for a customer named customer-1)
* client in keycloak for each box
* client-specific roles for each box, such as fhir_reader, fhir_writer
* client+service account+client id & secret in keycloak for customer-1 who will access their box.
* token introspector and access policies within boxes

Keycloak administration interface is available on http://keycloak.localhost:8081/auth

Multibox administration interface is available on http://multibox.localhost:8080

Username and password are both 'admin'

Run the repro script
```bash
cd stack
./repro.sh
```
The script will: 
* Exchange the client id + secret for an access token
* try to access the FHIR endpoint of the customer-1 box

The first time you run this after booting the stack, it will fail.

If you reboot multibox and run the script again
```bash
cd stack
docker restart multibox.localhost
sleep 10
./repro.sh
```

Then the request to the FHIR server will work (SUCCESS is echoed in the console).
This demonstrates some caching problem is preventing authentication/authorization until the server is rebooted.

Note you can tear down the containers with the stop script
```bash
cd stack
./stop.sh
```