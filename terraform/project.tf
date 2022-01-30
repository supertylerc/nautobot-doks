locals {
  project_resources = [
    digitalocean_kubernetes_cluster.k8s.urn
  ]
}

resource "digitalocean_project" "project" {
  name        = var.project_name
  description = "A project to work on Nautobot"
  purpose     = "Nautobot Test Environment"
  environment = "Development"
  resources   = local.project_resources
}
