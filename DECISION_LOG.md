# Decision Log

This document contains a log of major decisions made during the development of this project.
A decisions provides context on the project and the reasons behind certain choices.

## Decisions
The most recent decision should be at the top.

### 2025-12-03 Leveraging Gateway API

We've decided NOT to deploy our own Gateway API implementation, opting instead to just use the one provided by GKE. This allows us to save money over Ingress (because we don't need a separate ALB per app exposed to the net) without requiring us to maintain another piece of software.

See https://github.com/gpo/gpo-platform-configs/issues/119 for further discussion.

### 2025-12-02 Deployment Configuration Storage (central location vs close to app source)

We've decided to consolidate deployment configurations in gpo-platform-configs for now. This is a very reversible decision and keeping them together is the path of least resistance.

See https://github.com/gpo/gpo-platform-configs/issues/114 for discussion.

### 2025-11-27 How should we get TF output into K8s?

We need to funnel information about resources created by TF into K8s so our workloads can access them.

See https://github.com/gpo/gpo-platform-configs/issues/111 for detailed discussion.

Decision: we've opted for a loose coupling (unlike the suggestion noted on 2025-01 below), we will produce some lightweight tooling to fetch outputs from TF and munge them for delivery into K8s.

### 2025-01-21 Should we use Helm Charts?

Helm charts provides templating, which provides a flexible way to deploy into multiple environment based on values from that environment. This greatly reduces the spread that logic across CI/CD tools.

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

### 2024-12 How should we share secrets?

We landed on sops because it's simple and we know it:
- https://github.com/gpo/gpo-platform-configs/issues/30
- https://github.com/gpo/gpo-platform-configs/pull/31

Should we revisit this decision?
