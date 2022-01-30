resource "digitalocean_tag" "network_tags" {
  for_each = toset(var.node_tags)
  name = each.value
}

resource "digitalocean_firewall" "allow_dns" {
  name = "allow-dns-out"

  tags = [for t in digitalocean_tag.network_tags: t.id]

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_firewall" "allow_http_https" {
  name = "allow-http-and-https-out"

  tags = [for t in digitalocean_tag.network_tags: t.id]

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }
}
