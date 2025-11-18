# Superset

This is stuff needed for Superset. Need to find out how to organize this and which directory to put it in later. Will we be using kubectl? Argo CD? Terraform? etc

To spin things up or down, first set env var `KUBECONFIG` to a kubeconfig file for the cluster and make sure the right active context is set in that kubeconfig.

To spin things up, run `deploy.sh`.

To spin things down, run `down.sh`. Note that this retains the `ManagedCertificate`. See script for why.
