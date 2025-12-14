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

for file in cert.yaml gateway.yaml; do
  echo "applying ${env}/${file} to ${context}"
  kubectl apply -n gateway -f ${env}/${file}
done

echo "applying cert-manager letsencrypt certificate issuers"
kubectl apply -n gateway -f resources/issuer.prod.yaml
kubectl apply -n gateway -f resources/issuer.stage.yaml
