#!/bin/bash

helm template alpha --version v1.19.1 oci://quay.io/jetstack/charts/cert-manager -n cert-manager -f values.yaml | kubectl apply -f -
