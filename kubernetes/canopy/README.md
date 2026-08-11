# Canopy

The GKE-hosted WordPress multisite network (`gpo/canopy`). Testing ground
domain is `gpogear.ca`, wildcarded - not `gpo.ca` or `islandgetaway.ca`.
See `DECISION_LOG.md` for why this has its own dedicated Gateway instead of
joining `gpotools`'.

### Bootstrapping a new environment's Gateway

Same chicken/egg problem as `../gateway`: you can't get a functional Gateway
with a TLS listener until a cert exists in a secret, and cert-manager can't
issue that cert into a secret until `canopy-ingress-ip` is reserved and a
Gateway exists for the DNS-01 challenge to resolve against. Bootstrap order:

```
kubectl apply -n canopy -f gateway.bootstrap.yaml
# wait for wildcard-cert.yaml's Certificate to go Ready
kubectl apply -n canopy -f stage/rendered/gateway.yaml   # (or prod/rendered/gateway.yaml)
```

After that, ArgoCD (see `kubernetes/argocd-apps/stage/application.yaml`) handles routine updates automatically.
