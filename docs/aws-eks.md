# AWS / EKS

Modules: `tf/modules/infra/eks/`, `tf/modules/infra/vpc/`, `tf/modules/infra/ecr/`
Instantiated in: `tf/infra/prod/main.tf`, `tf/infra/stage/main.tf`

## Accounts and profiles

| Environment | Account ID | AWS CLI profile |
|---|---|---|
| prod | `060795914812` | `gpo-prod` |
| stage | `542371827759` | `gpo-stage` |

Region: `ca-central-1` for both.

## VPC layout

CIDR `10.0.0.0/16`. Three subnets:
- Public `10.0.0.0/20` (ca-central-1a) — NAT gateway lives here
- Private active `10.0.16.0/20` (ca-central-1a) — EKS nodes
- Private inactive `10.0.32.0/20` (ca-central-1b) — required by EKS, no nodes

`nat_gateway_public_ip` output = source IP for all outbound cluster traffic.

## EKS

Cluster `gpo-prod` / `gpo-stage`. `desired_size` is ignored by Terraform (managed by cluster autoscaler). User access via EKS access entries — ARNs flow from bootstrap outputs.

## ECR

Repos named `gpo/<name>`. Lifecycle: keep last 30 images. Add repos by extending the `repositories` list in the `ecr` module call in `tf/infra/{prod,stage}/main.tf`.
