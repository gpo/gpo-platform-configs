# K8s Organization

Each subdir here represents a logical grouping of K8s resources. Often a subdir represents a discrete set of workloads that run in the same nespace, but there are exceptions (eg. `./argocd/` contains configs for deploying argocd itself while `./argocd-apps/` contains our [`Application`](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) resources, which all live in the `argocd` namespace).

## A word about manifests

We have adopted the [rendered manifests pattern](https://akuity.io/blog/the-rendered-manifests-pattern). Which is to say, ArgoCD does NO templating of any kind. It just reads from github and applies to K8s. See the [decision log](../DECISION_LOG.md) for rationale.

## Applying

All our K8s resources are managed by ArgoCD. In an ideal world, no one should ever by `kubectl apply`ing to prod.

> Note: we do not yet live in an ideal world 🌏

## Templating

There are three levels of templating in effect.

### Level 0 - raw YAML

Static manifests live under the `./resources/` subdir for a given workload. Workloads which can be deployed by simply applying a static manifest have the simplest configuration. [CNPG](./cnpg) is a good example of this pattern. CNPG best practices recommend simply [applying a big manifest](https://cloudnative-pg.io/docs/1.27/installation_upgrade/) to deploy their operator so we just vendored it into our repo.

### Level 1 - just helm

Some workloads we can get away with using static values to render a chart. [Cert Manager](./cert-manager) is a good example of this. We use a [helmfile](https://helmfile.readthedocs.io/en/latest/) for every workload that uses a helm chart to pin chart repos and versions. We have a separate `./stage/` and `./prod/` copy of `helmfile.yaml` and `values.yaml` so we can test changes in stage without affecting prod.

**Conventions:**
* `./<workload>/stage/helmfile.yaml` `./<workload>/prod/helmfile.yaml`
  * helmfile for each environment pins chart repo and chart version.

* `./<workload>/stage/values.yaml` `./<workload>/prod/values.yaml`
  * values file for each environment encodes our preferences, allows testing new things in stage before committing to them in prod.

* `./<workload>/stage/rendered/<workload>.yaml` `./<workload>/prod/rendered/<workload>.yaml`
  * the final render of the whole chart goes into the ./rendered/ subdir.

To render all helm charts in the repo run `mise render`.

To render a helm chart for a specific workload run `mise <workload_name>:render`.

### Level 2 - "genk8s"

> A tool for feeding tf output into K8s.

Workloads which can get by with basic templating are currently rendered with a fairly hacky script called [genk8s.sh](../scripts/genk8s.sh). We [have plans to replace this](https://github.com/gpo/gpo-platform-configs/issues/141) with something more robust but for now here we are.

`genk8s` exists to take the outputs from the [application level tf](../tf/app/) and feed them into kubernetes. Eg. if we create a DNS record foo.gpotools.ca and the foo tool needs to know its own hostname so it can route traffic, `genk8s` handles that mapping.

**Conventions:**

* `genk8s` templates live in the `./templates/` subdir for a given workload.
* `genk8s` expects a root level tf output which has the same name as the workload subdir.
* `genk8s` expects a child output for each template in the `./templates` subdir.
   * eg. for `./kubernetes/foo/templates/httproute.yaml.tmpl`
   * `tofu output foo` must produce: `{"httproute" = { "hostname" = "foo.gpotools.ca"}}`

Concrete example: have a look at [the current tf outputs for staging](../tf/app/stage/outputs.tf) and compare them to [the gateway templates](./gateway/templates/).

To run `genk8s` across the whole repo run `mise genk8s`.

To run `genk8s` for a specific workload run `mise <workload_name>:genk8s`.

To run `genk8s` for a specific workload in a specific environment (stage/prod) run `mise <workload_name>:genk8s:<environment>`.

### Level 2 - "genk8s" + helm

> For when you need to generate helm values dynamically from tf outputs.

For workloads which recommend deploying with helm, but which also require feeding tf outputs into helm values. A good example of this is [argocd](./argocd/). First we run `mise argocd:genk8s` to fetch the tf outputs and use them to render a [templated values file](./argocd/templates/values.yaml.tmpl) for each of `./argocd/stage/` and `./argocd/prod/`. Then we run `mise argocd:render` to use those tf outputs in the values file to render the argocd helm chart.
