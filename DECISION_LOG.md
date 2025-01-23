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

### 2025-01 Where should we keep `yml` with resources deployment definitions for Kubernetes?

Options:
- Keep it in https://github.com/gpo/gpo-platform-configs
- Create a separate repo just for Kubernetes yml
- keep it in the repos of the services

We want new people coming into this workspace to easily find what they are looking for. Multiple repos makes that more difficult.
Keeping files in each service makes that service responsible for it's deployment. This might be something we do long term but as were starting out it's more desirable to keep all the K8s files together. This will lead to faster iteration and better learning and standardization.

Decision: Move Terraform into a subdirectory of this repo and put Kubernetes yml in a separate directory.


### 2025-01 Should we use Terraform for managing things inside Kubernetes?

One case where using TF to put stuff into K8s is useful is configuration / secrets. Eg. if we create an RDS instance with TF and then put the connection string into a K8s secret. There are other ways to approach this (glue TF outputs into Helm inputs) but worth considering.

Terraform is good at managing static infrastructure, it's not as good at managing constantly changing infrastructure like inside Kubernetes. We'll use Kubernetes yml or similar to manage Kubernetes.

Decision: Generally NO, but not a strict ban.
