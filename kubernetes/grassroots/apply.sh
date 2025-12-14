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

k="kubectl --context ${context} -n grassroots"

for file in deployment.yaml httproute.yaml; do
  echo "applying ${env}/${file} to ${context}"
  $k apply -f ${env}/${file}
done

echo "applying encrypted resources"
sops decrypt --input-type yaml --output-type yaml ${env}/secret.yaml.enc | $k apply -f -

echo "applying static resources"
$k apply -f ./resources
