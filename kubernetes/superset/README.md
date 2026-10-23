# Superset

This is stuff needed for Superset. It's a Helm chart and a few Kubernetes resources.

To deploy or undeploy Superset, first set env var `KUBECONFIG` to a kubeconfig file for the cluster and make sure the right active context is set in that kubeconfig.

# Deploy

If needed, add the Superset helm repo.

```sh
helm repo add superset http://apache.github.io/superset/
```

If needed, initialize all OpenTofu states in the project (check `app`, `bootstrap`, and `infra`).

```sh
tofu init
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
    superset/superset --values kubernetes/superset/stage/values.yaml \
    --set extraSecretEnv.SUPERSET_SECRET_KEY="$superset_secret_key" \
    --set init.adminUser.password="$superset_admin_user_pass"' \
  && kubectl apply -n superset -f kubernetes/superset/stage/httproute.yaml \
     -f kubernetes/superset/resources/
```

PROD

```sh
sops exec-env secrets.prod.env \
  'helm upgrade -n superset --install superset \
    superset/superset --values kubernetes/superset/prod/values.yaml \
    --set extraSecretEnv.SUPERSET_SECRET_KEY="$superset_secret_key" \
    --set init.adminUser.password="$superset_admin_user_pass"' \
  && kubectl apply -n superset -f kubernetes/superset/prod/httproute.yaml \
     -f kubernetes/superset/resources/
```

This combines the values in values.yaml with the values that are secrets, by pulling the secrets from SOPS, and deploys Superset. It also deploys the `HTTPRoute` to route traffic through our gateway into superset.

# Undeploy

To undeploy Superset, run:

```sh
helm uninstall -n superset superset
kubectl delete -f kubernetes/superset/<stage|prod>/ -f kubernetes/superset/resources/
```

# MCP server

Superset ships a built-in [MCP server](https://superset.apache.org/admin-docs/configuration/mcp-server)
(`superset mcp run`) that lets MCP clients (Claude, Cursor, etc.) drive Superset
through its existing RBAC. We run it **stage only** for now as a sidecar in the
Superset web pod (`supersetNode.extraContainers` in `stage/values.yaml`),
listening on port `5008`. The `superset-mcp` Service exposes it in-cluster and
the `HTTPRoute` routes `https://superset.gpotoolsstage.ca/mcp` to it.

Auth is HS256 JWT (`MCP_AUTH_ENABLED = True`): clients send a bearer token signed
with the shared secret `MCP_JWT_SECRET`. RBAC is enforced on every tool call.

## What lives where

- **Image** — `fastmcp` is added in `docker/Dockerfile` (not reliably bundled in
  the 6.1.0 base), so the image must be rebuilt and the tag bumped to `v0.0.4`.
- **Sidecar + intent config** — `stage/values.yaml` (`extraContainers` and the
  `MCP_*` block in `configOverrides`).
- **Service** — `stage/mcp-service.yaml` (the chart only makes the web Service).
- **Route** — the `/mcp` rule in `stage/httproute.yaml`.

> Note: these edits are made directly in the `stage/` files (as the brand-theme
> change was), **not** in `templates/`. The values template is already stale
> (it predates the theme), so running `mise superset:genk8s` would regress both
> the theme and this change — avoid it for superset until the template is
> reconciled.

## Required out-of-band steps

The deployed config and env do **not** come from this repo's `configOverrides`:
`filter-helm-templates.sh` strips the helm-generated `superset-config` and
`superset-env` Secrets, and External Secrets replaces them from GCP Secret
Manager. So before this works at runtime:

1. **Build and push the image with `fastmcp`, tagged `v0.0.4`:**

   ```sh
   mise superset:build
   # tag + push the result to the stage Artifact Registry as
   # .../apache-superset:v0.0.4
   ```

2. **Sync `superset_config.py` to the GCP SM `superset-config` secret** — the
   value that's actually mounted. It must include the `MCP_*` block from
   `stage/values.yaml` (alongside the existing theme/feature flags).

3. **Add `MCP_JWT_SECRET` to the GCP SM `superset-env` secret** — a strong random
   value used to sign and verify the JWTs.

ArgoCD then syncs `stage/rendered` + `stage/`.

## Connecting a client

Mint an HS256 JWT signed with `MCP_JWT_SECRET`, with `iss = gpo-superset-mcp`
and `aud = superset-mcp-stage`, then point your client at the endpoint:

```json
{
  "mcpServers": {
    "superset": {
      "type": "url",
      "url": "https://superset.gpotoolsstage.ca/mcp",
      "headers": { "Authorization": "Bearer <token>" }
    }
  }
}
```
