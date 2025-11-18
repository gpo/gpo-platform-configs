#!/bin/env bash

# Deploys Superset by applying the chart with our values.yaml file and an
# Ingress. We may use the Ingress to expose other apps in the future too. Using
# one Ingress instead of one per exposed app allows us to minimize GCP cloud
# cost because GCP charges $18/mo per forwarding rule, and you get a forwarding
# rule for each Ingress you deploy.

if [ -z "$KUBECONFIG" ]; then
  echo "KUBECONFIG is not set"
else
  echo "KUBECONFIG is set"
fi

helm repo add superset https://apache.github.io/superset

helm upgrade -n superset --install superset superset/superset --values values.yaml

kubectl apply -f resources/ingress.yaml
kubectl apply -f resources/managedcertificate.yaml
