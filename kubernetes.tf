resource "digitalocean_kubernetes_cluster" "main_cluster" {
  name          = data.digitalocean_kubernetes_cluster.main_cluster.name
  region        = "nyc3"
  auto_upgrade  = true
  surge_upgrade = true
  ha            = false # TODO: Before moving over secure.gpo.ca or gpo.ca turn this on
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.31.1-do.1"

  #TODO: Do I need a VPC?

  maintenance_policy {
    start_time = "08:00" // 3am EST or 4am EDT
    day        = "sunday"
  }

  node_pool {
    #TODO: look into all this. What does it mean?
    name       = "worker-pool"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
    # `doctl kubernetes options sizes`
    size = "s-4vcpu-8gb-intel"

    taint {
      key    = "workloadKind"
      value  = "database"
      effect = "NoSchedule"
    }
  }
}
