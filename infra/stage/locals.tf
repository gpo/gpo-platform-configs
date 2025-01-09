locals {
  project_name           = "gpo"
  environment            = "stage"
  nodegroup_desired_size = 1
  nodegroup_max_size     = 5
  nodegroup_min_size     = 1
}
