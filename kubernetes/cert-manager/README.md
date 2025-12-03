A quick and dirty Cert Manager installation to enable us to serve TLS requests.

We are currently using the http01 solver (see ../gateway/resources/issuer.prod.yaml)
however this creates annoying problems (see ../gateway/resources/gateway.bootstrap.yaml).

We should switch to the dns01 solver ASAP.
