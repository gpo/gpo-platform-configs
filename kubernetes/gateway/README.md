# Gateway API & Cert Manager

This directory configures our GCP load balancer using the Gateway API. This
is the main entry point for traffic arriving at our cluster. This configuration
requires [Cert Manager](https://cert-manager.io/) to be up and running in order
to serve TLS encrypted requests.

### Deploying

kubectl apply -n gateway -f resources/gateway.yaml -f resources/issuer.prod.yaml -f resources/cert.yaml


### TODOs

This directory needs templating & integration with genk8s.sh to dynamically produce listeners
with the right hostnames.
