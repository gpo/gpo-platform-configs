#!/bin/bash

env=$1;shift

if [[ $env = "prod" ]]; then
  context=gke_gpo-eng-prod_northamerica-northeast2-a_gpo-prod
elif [[ $env = "stage" ]]; then
  context=gke_gpo-eng-stage_northamerica-northeast2-a_gpo-stage
else
  echo "You must provide an environment name argument: prod or stage."
  exit 1
fi

k="kubectl --context ${context}"

$k apply --server-side -f ./resources
