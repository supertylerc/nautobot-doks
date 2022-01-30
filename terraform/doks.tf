data "digitalocean_kubernetes_versions" "k8s" {
  version_prefix = var.kubernetes_version
}

data "digitalocean_sizes" "k8s" {
  filter {
    key    = "slug"
    values = [var.size]
  }

  filter {
    key    = "regions"
    values = [var.region]
  }

}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = var.cluster_name
  region  = var.region
  version = data.digitalocean_kubernetes_versions.k8s.latest_version

  auto_upgrade = var.auto_upgrade
  tags         = var.tags

  node_pool {
    name       = var.cluster_name
    size       = element(data.digitalocean_sizes.k8s.sizes, 0).slug
    auto_scale = var.auto_scale
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
    node_count = var.node_count
    tags       = var.node_tags
    labels     = var.node_labels
  }
  maintenance_policy {
    start_time  = var.maintenance_policy_start_time
    day         = lower(var.maintenance_policy_day)
  }

}
