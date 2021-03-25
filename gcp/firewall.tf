# firewall
# resource "google_compute_firewall" "gke_masters" { 
#   name = "masters-firewall-ingress-rule"
#   project = google_project.this.name
#   network = google_compute_network.gke_net.self_link
#   priority = 100
#   source_ranges = [google_container_cluster.this.private_cluster_config[0].master_ipv4_cidr_block]
#   allow {
#     protocol = "tcp"
#     ports = ["1-65535"]
#   }
# }
