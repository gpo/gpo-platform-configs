# Superset

This is stuff needed for Superset. It's a Helm chart and a few Kubernetes resources.

To deploy or undeploy Superset, first set env var `KUBECONFIG` to a kubeconfig file for the cluster and make sure the right active context is set in that kubeconfig.

# Deploy

If needed, add the Superset helm repo.

```sh
helm repo add superset http://apache.github.io/superset/
```

To generate dynamic YAMLs for superset run:

```sh
mise superset:genk8s
```

To deploy Superset, from the root of the repo, run:

STAGING

```sh
sops exec-env secrets.stage.env \
  'helm upgrade -n superset --install superset \
    superset/superset --values kubernetes/superset/stage/values-dynamic.yaml \
    --set extraSecretEnv.SUPERSET_SECRET_KEY="$superset_secret_key" \
    --set init.adminUser.password="$superset_admin_user_pass"' \
  && kubectl apply -n superset -f kubernetes/superset/stage/httproute-dynamic.yaml \
     -f kubernetes/superset/resources/
```

PROD

```sh
sops exec-env secrets.prod.env \
  'helm upgrade -n superset --install superset \
    superset/superset --values kubernetes/superset/prod/values-dynamic.yaml \
    --set extraSecretEnv.SUPERSET_SECRET_KEY="$superset_secret_key" \
    --set init.adminUser.password="$superset_admin_user_pass"' \
  && kubectl apply -n superset -f kubernetes/superset/prod/httproute-dynamic.yaml \
     -f kubernetes/superset/resources/
```

This combines the values in values.yaml with the values that are secrets, by pulling the secrets from SOPS, and deploys Superset. It also deploys the `HTTPRoute` to route traffic through our gateway into superset.

# Undeploy

To undeploy Superset, run:

```sh
helm uninstall -n superset superset
kubectl delete -f kubernetes/superset/<stage|prod>/ -f kubernetes/superset/resources/
```
