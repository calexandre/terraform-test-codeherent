# VPC for GKE
resource "google_compute_network" "default" {
  project                         = google_project.this.name
  name                            = "vpc-default-${var.env}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "subnet-default-${var.location}-1"
  network                  = google_compute_network.default.self_link
  ip_cidr_range            = "10.0.10.0/24"
  region                   = var.location
  project                  = google_compute_network.default.project
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "gke" {
  name                     = "subnet-gke-${var.location}-1"
  network                  = google_compute_network.default.self_link
  ip_cidr_range            = "10.25.0.0/16"
  region                   = var.location
  project                  = google_compute_network.default.project
  private_ip_google_access = true
}

# NAT setup for internet access
resource "google_compute_router" "default" {
  name    = "cr-${google_compute_network.default.name}-1"
  project = google_compute_network.default.project
  network = google_compute_network.default.self_link
  region  = google_compute_subnetwork.default.region
}

resource "google_compute_router_nat" "default" {
  name                               = "nat-${google_compute_network.default.name}-1"
  project                            = google_compute_network.default.project
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ALL"
  }
}
