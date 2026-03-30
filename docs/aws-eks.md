# AWS EKS Infrastructure

Relevant stacks: `tf/infra/prod/`, `tf/infra/stage/`
Relevant modules: `tf/modules/infra/eks/`, `tf/modules/infra/vpc/`, `tf/modules/infra/ecr/`

---

## AWS accounts

| Environment | Account ID | AWS CLI Profile |
|---|---|---|
| prod | 060795914812 | `gpo-prod` |
| stage | 542371827759 | `gpo-stage` |

Region: `ca-central-1` for both.

Both profiles must be configured in `~/.aws/credentials` / `~/.aws/config` before running any `tofu` commands.

---

## VPC

Module: `tf/modules/infra/vpc/`

### What it creates

| Resource | CIDR | AZ | Notes |
|---|---|---|---|
| VPC | `10.0.0.0/16` | — | With internet gateway |
| Public subnet | `10.0.0.0/20` | `ca-central-1a` | NAT gateway lives here |
| Private active subnet | `10.0.16.0/20` | `ca-central-1a` | EKS nodes run here |
| Private inactive subnet | `10.0.32.0/20` | `ca-central-1b` | Required by EKS, no nodes |

### Why two private subnets?

EKS requires subnets in at least two availability zones. The `inactive` subnet exists solely to satisfy this requirement; no nodes are scheduled there.

### Key output

- `nat_gateway_public_ip` — the source IP for all outbound traffic from the cluster. Useful for allowlisting.

---

## EKS cluster

Module: `tf/modules/infra/eks/`

### What it creates

- EKS cluster: `gpo-prod` / `gpo-stage`
- Access mode: API-based (not config-map)
- IAM role for the cluster with policies:
  - `AmazonEKSClusterPolicy`
  - `AmazonEKSComputePolicy`
  - `AmazonEKSBlockStoragePolicy`
  - `AmazonEKSLoadBalancingPolicy`
  - `AmazonEKSNetworkingPolicy`
- Managed node group in the active private subnet
- Node IAM role with:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryPullOnly`

### Node group scaling

```hcl
nodegroup_desired_size = ...
nodegroup_min_size     = ...
nodegroup_max_size     = ...
```

The `desired_size` change is **ignored by Terraform** (`ignore_changes = [scaling_config[0].desired_size]`) — the cluster autoscaler manages desired count at runtime.

### User access

Access entries are created for each user ARN in `var.admin_user_arns` and `var.eks_user_arns`:

| User type | Policy |
|---|---|
| Admin | `AmazonEKSClusterAdminPolicy` |
| EKS user | `AmazonEKSAdminPolicy` |

---

## ECR (Elastic Container Registry)

Module: `tf/modules/infra/ecr/`

### What it creates

- One ECR repository per name in `var.repositories`
- Repository path: `gpo/<name>`
- Lifecycle policy: keep last 30 images, expire older ones

### Adding a new ECR repository

In `tf/infra/{prod,stage}/main.tf`, add the repo name to the `repositories` list in the `ecr` module call:

```hcl
module "ecr" {
  source       = "../../modules/infra/ecr"
  repositories = ["existing-repo", "my-new-repo"]
}
```

---

## AWS provider configuration

```hcl
provider "aws" {
  profile = "gpo-prod"   # or "gpo-stage"
  region  = "ca-central-1"
}
```

The profile name comes from the local `environment` value. Bootstrap state provides IAM user ARNs to downstream stacks.
