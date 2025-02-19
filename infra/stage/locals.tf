locals {
  project_name = "gpo"
  environment  = "stage"
  /* eks specific */
  nodegroup_desired_size = 1
  nodegroup_max_size     = 5
  nodegroup_min_size     = 1
  /* ecr specific */
  repositories = ["donor-history-report"]
}
