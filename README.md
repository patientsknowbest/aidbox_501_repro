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
* 2x multibox instances backed by the same database (HA mode multibox)
* nginx load balancer in front of the two instances
* multiple boxes within multibox
* client in keycloak for each box
* client-specific roles for each box, such as fhir_reader, fhir_writer
* client+service account+client id & secret in keycloak for customer-1 who will access their box.
* token introspector and access policies within boxes
* locust load tester

Locust web UI is available on: http://localhost:8089/ and host parameter & env vars are pre-set to access the 'aggregate' box in aidbox.

locustfile.py contains 2 tasks to put and get /fhir/Appointment resources. Press 'Start swarming' to load test.

Note you can tear down the containers with the stop script
```bash
cd stack
./stop.sh
```