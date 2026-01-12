# GPO Cloud Platform

## Google

We have two (mostly) isolated environments, which are (almost) entirely based in google cloud. Isolation between environments is provided by separate GCP projects, with a small amount of shared bootstrap infrastructure.

* [Stage Project](https://console.cloud.google.com/welcome?project=gpo-eng-stage)
* [Prod Project](https://console.cloud.google.com/welcome?project=gpo-eng-prod)
* [Bootstrap Project](https://console.cloud.google.com/welcome?project=gpo-bootstrap-2).

### Specifically, shared infra consists of:
* one bucket for all of our TF state files called [gpo-tf-state-data](https://console.cloud.google.com/storage/browser?project=gpo-bootstrap-2&prefix=&forceOnBucketsSortingFiltering=true&bucketType=live)
* [two KMS keys](https://console.cloud.google.com/security/kms/keyrings?project=gpo-bootstrap-2) (one for prod, one for stage) used to manage sops secrets which are used by stage/prod TF to authenticate to cloud APIs (eg. cloudflare)
  * Key use is configured in [`.sops.yaml`](../.sops.yaml)
  * Secrets are consumed in various `secrets.tf` files eg. [./tf/app/stage/secrets.tf](../tf/app/stage/secrets.tf]

## Kubernetes

In each environment the primary resources are the GKE clusters in which most of our workloads are running.

At present, all GCP resources which are not global exist in the northamerica-northeast2-a (AKA Toronto) availability zone.

Our clusters leverage the following technologies to support our workloads.

* [Gateway API](https://gateway-api.sigs.k8s.io/api-types/gateway/) powered by the [GKE Gateway controller](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/gateway-api#gateway_controller) to route traffic from the internet into our workloads.
* [Cert Manager](https://cert-manager.io/) powered by [Lets Encrypt](https://letsencrypt.org/) to secure our traffic with TLS certificates.
* [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) to provide gitops based continuous delivery.
* [Cloud Native Postgres](https://cloudnative-pg.io/) to manage in-cluster postgres databases for our workloads.

## Monitoring

### Prod

[Prod GKE cluster](https://console.cloud.google.com/kubernetes/clusters/details/northamerica-northeast2-a/gpo-prod/overview?project=gpo-eng-prod).

[Prod ArgoCD](https://argocd.gpotools.ca/)

> See [#169](https://github.com/gpo/gpo-platform-configs/issues/169) for access.

[Prod Workloads](https://console.cloud.google.com/kubernetes/workload/overview?project=gpo-eng-prod)

[Prod HTTP LB Traffic](https://console.cloud.google.com/monitoring/dashboards/resourceList/l7_lb_rule?project=gpo-eng-prod)

---

### Stage

[Stage GKE cluster](https://console.cloud.google.com/kubernetes/clusters/details/northamerica-northeast2-a/gpo-stage/overview?project=gpo-eng-stage)

[Stage ArgoCD](https://argocd.gpotoolsstage.ca/)

> See [#169](https://github.com/gpo/gpo-platform-configs/issues/169) for access.

[Stage Workloads](https://console.cloud.google.com/kubernetes/workload/overview?project=gpo-eng-stage)

[Stage HTTP LB Traffic](https://console.cloud.google.com/monitoring/dashboards/resourceList/l7_lb_rule?project=gpo-eng-stage)
