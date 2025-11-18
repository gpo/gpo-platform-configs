#!/bin/env bash

# Undeploys Superset by uninstalling the Helm chart and deleting the Ingress (but
# not the ManagedCertificate). We aren't deleting the `ManagedCertificate` each time
# we spin down because it takes GCP 30-60 mins to fully provision certs.

if [ -z "$KUBECONFIG" ]; then
  echo "KUBECONFIG is not set"
else
  echo "KUBECONFIG is set"
fi

helm uninstall -n superset superset
kubectl delete ingress exposed-apps -n superset

