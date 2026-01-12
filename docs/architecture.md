# GPO Cloud Platform

## Overview

### Google

We have two (mostly) isolated environments, [stage](https://console.cloud.google.com/welcome?project=gpo-eng-stage) and [prod](https://console.cloud.google.com/welcome?project=gpo-eng-prod) which are (almost) entirely based in google cloud.

Isolation between environments is provided by separate GCP projects, with a small stub of shared [bootstrap infrastructure](https://console.cloud.google.com/welcome?project=gpo-bootstrap-2).

In each environment the primary resources are the GKE clusters in which most of our workloads are running.

At present, all GCP resources which are not global exist in the northamerica-northeast2-a (AKA Toronto) availability zone.

### Kubernetes

Our clusters leverage the following technologies to support our workloads.

* [Gateway API](https://gateway-api.sigs.k8s.io/api-types/gateway/) powered by the [GKE Gateway controller](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/gateway-api#gateway_controller) to route traffic from the internet into our workloads.
* [Cert Manager](https://cert-manager.io/) powered by [Lets Encrypt](https://letsencrypt.org/) to secure our traffic with TLS certificates.
* [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) to provide gitops based continuous delivery.
* [Cloud Native Postgres](https://cloudnative-pg.io/) to manage in-cluster postgres databases for our workloads.


## Monitoring

### Prod

[Prod GKE cluster](https://console.cloud.google.com/kubernetes/clusters/details/northamerica-northeast2-a/gpo-prod/overview?project=gpo-eng-prod).

[Prod ArgoCD](https://argocd.gpotools.ca/)

[Prod Workloads](https://console.cloud.google.com/kubernetes/workload/overview?project=gpo-eng-prod)

> See #169 for access.

---

### Stage

[Stage GKE cluster](https://console.cloud.google.com/kubernetes/clusters/details/northamerica-northeast2-a/gpo-stage/overview?project=gpo-eng-stage)

[Stage ArgoCD](https://argocd.gpotoolsstage.ca/)

> See #169 for access.

[Stage Workloads](https://console.cloud.google.com/kubernetes/workload/overview?project=gpo-eng-stage)
