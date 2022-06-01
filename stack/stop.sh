#!/usr/bin/env bash

## Remove all docker objects with e2e label
containers=$(docker ps -aq --filter="label=io.pkb.e2e=true")
if [ "$containers" != "" ]; then
  docker container rm $(docker stop -t 1 ${containers})
fi 

volumes=$(docker volume ls -q --filter="label=io.pkb.e2e=true")
if [ "$volumes" != "" ]; then
  docker volume rm ${volumes}
fi 

networks=$(docker network ls -q --filter="label=io.pkb.e2e=true")
if [ "$networks" != "" ]; then
  docker network rm ${networks}
fi 

## Wipe all terraform state
find . -depth -type d -name '*.state' -exec rm -rf {} \; || true
find . -depth -type d -name '*.terraform' -exec rm -rf {} \; || true
find . -depth -type f -name '*.tfvars*' -delete || true