locals {
  kubeconfig_template = "k8s/.templates/kubeconfig-template.yaml"
  kubeconfig_filename = "kubeconfig.yaml"
  default_gke = {
    cluster_name    = "default-gke"
    location        = var.location
    release_channel = "RAPID"

    private_cluster_config = {
      enable_private_endpoint = false
      enable_private_nodes    = true
    }

    master_auth = {
      username = "administrator"
      password = random_password.password.result
    }

    workload_identity_config = {
      identity_namespace = "${google_project.this.project_id}.svc.id.goog"
    }

    primary_pool = {
      name         = "primary-pool"
      machine_type = "e2-standard-2"
      disk_size_gb = "50"
      image_type   = "cos_containerd"
      preemptible  = true
      tags         = ["gke-nodes", "gke-preemptible-pool", "gke-${google_project.this.name}"]
    }
  }
}

resource "google_container_cluster" "default" {
  name           = local.default_gke.cluster_name
  project        = google_project.this.name
  provider       = google
  location       = local.default_gke.location

  network                   = google_compute_network.default.self_link
  subnetwork                = google_compute_subnetwork.gke.self_link
  default_max_pods_per_node = 64

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  enable_binary_authorization = false
  enable_kubernetes_alpha     = false
  enable_legacy_abac          = false

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = local.default_gke.release_channel
  }

  addons_config {
    # The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods
    horizontal_pod_autoscaling {
      disabled = false
    }

    # The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster
    http_load_balancing {
      disabled = false
    }

    ## you need to use google-beta provider to use this
    # istio_config {
    #   disabled = true
    #   auth = "AUTH_MUTUAL_TLS"
    # }
  }

  cluster_autoscaling {
    enabled = false
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/24"
  }

  maintenance_policy {

    recurring_window {
      end_time   = "2020-04-11T05:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH"
      start_time = "2020-04-11T01:00:00Z"
    }
  }

  # If this block is provided and both username and password are empty, basic authentication will be disabled. 
  # If this block is not provided, GKE will generate a password for you with the username admin.
  master_auth {
    username = local.default_gke.master_auth.username
    password = local.default_gke.master_auth.password

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network_policy {
    enabled = false
  }

  private_cluster_config {
    enable_private_endpoint = local.default_gke.private_cluster_config.enable_private_endpoint
    enable_private_nodes    = local.default_gke.private_cluster_config.enable_private_nodes
    master_ipv4_cidr_block  = "10.0.1.0/28"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = local.default_gke.workload_identity_config.identity_namespace
  }

  lifecycle {
    ignore_changes = [
      node_pool
    ]
  }

  depends_on = [
    google_compute_router.default,
    google_compute_router_nat.default,
    google_project_service.this
  ]
}

## primary node pool - we disabled the default to ensure recommended practices
resource "google_container_node_pool" "primary" {
  name               = local.default_gke.primary_pool.name
  cluster            = google_container_cluster.default.name
  initial_node_count = 1
  max_pods_per_node  = 64
  location           = google_container_cluster.default.location

  node_config {
    disk_size_gb = local.default_gke.primary_pool.disk_size_gb
    machine_type = local.default_gke.primary_pool.machine_type
    image_type   = local.default_gke.primary_pool.image_type
    preemptible  = local.default_gke.primary_pool.preemptible
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = local.default_gke.primary_pool.tags
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 6
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 0
  }

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}

output "gke_default_node_version" {
  value = google_container_cluster.default.node_version
}

output "gke_default_endpoint" {
  value = google_container_cluster.default.endpoint
}

## Kubeconfig automatic generation
## More info: https://github.com/hashicorp/terraform-provider-kubernetes/tree/master/kubernetes/test-infra/gke
data "template_file" "kubeconfig" {
  template = file(local.kubeconfig_template)

  vars = {
    cluster_name    = google_container_cluster.default.name
    user_name       = google_container_cluster.default.master_auth[0].username
    user_password   = google_container_cluster.default.master_auth[0].password
    endpoint        = google_container_cluster.default.endpoint
    cluster_ca      = google_container_cluster.default.master_auth[0].cluster_ca_certificate
    client_cert     = google_container_cluster.default.master_auth[0].client_certificate
    client_cert_key = google_container_cluster.default.master_auth[0].client_key
    #token           = data.google_client_config.this.access_token # this causes a terraform perma-diff because the token is always changing
    token = ""
  }
}


resource "local_file" "kubeconfig" {
  sensitive_content = data.template_file.kubeconfig.rendered
  filename          = local.kubeconfig_filename
}

output "gke_default_kubeconfig" {
  value = "export KUBECONFIG=${local.kubeconfig_filename} && gcloud container clusters get-credentials ${google_container_cluster.default.name} --region ${google_container_cluster.default.location} --project ${google_container_cluster.default.project}"
}
