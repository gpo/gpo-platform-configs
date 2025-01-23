# Decision Log

This document contains a log of major decisions made during the development of this project.
A decisions provides context on the project and the reasons behind certain choices.

## Decisions
The most recent decision should be at the top.

### 2025-01-21 Should we use Helm Charts?

- more complex
- there are easier options
- has high name recognition
- very reversible decision: export the yaml

Decision: Since it's very reversible. Go with Helm for now and readjust in the future

### 2025-01 Where should we keep yml for Kubernetes?

Options:
- Keep it in this repo
- Create a separate repo just for Kubernetes yml
- keep it in the repos of the services

Decision: Move Terraform into a subdirectory of this repo and put Kubernetes yml in a separate directory.


### 2025-01 Should we use Terraform for managing things inside Kubernetes?

One case where using TF to put stuff into K8s is useful is configuration / secrets. Eg. if we create an RDS instance with TF and then put the connection string into a K8s secret. There are other ways to approach this (glue TF outputs into Helm inputs) but worth considering.

Terraform is good at managing static infrastructure, it's not as good at managing constantly changing infrastructure like inside Kubernetes. We'll use Kubernetes yml or similar to manage Kubernetes.

Decision: Generally NO, but not a strict ban.
