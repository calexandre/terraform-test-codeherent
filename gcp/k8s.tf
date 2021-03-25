locals {
  hipster_fqdn = trim("hipster.${local.fqdn}",".")
}

provider "kubectl" {
  host                   = google_container_cluster.default.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ## used by gcloud auth provider (recommended)
  token                  = data.google_client_config.this.access_token

  ## used with client-certificate auth
  # client_certificate     = google_container_cluster.default.master_auth[0].client_certificate
  # client_key             = google_container_cluster.default.master_auth[0].client_key

  ## used for basic auth
  # username         = google_container_cluster.default.master_auth[0].username
  # password         = google_container_cluster.default.master_auth[0].password

  load_config_file = false
}

# not needed for now
# provider "kubernetes" {
#   host                   = google_container_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)
#   token                  = data.google_client_config.this.access_token
#   load_config_file       = false
# }

## cert-manager
data "kubectl_file_documents" "cert_manager" {
  content = file("k8s/cert-manager/00-manifest.yaml")
}

resource "kubectl_manifest" "cert_manager" {
  count     = length(data.kubectl_file_documents.cert_manager.documents)
  yaml_body = element(data.kubectl_file_documents.cert_manager.documents, count.index)

  depends_on = [ 
    google_container_cluster.default, 
    google_container_node_pool.primary 
  ]
}

resource "time_sleep" "cert_manager_webhook_ready" {
  create_duration = "60s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    cert_manager_live_uid = kubectl_manifest.cert_manager[0].live_uid
  }
}

# cert-manager letsencrypt cluster-issuer
data "kubectl_path_documents" "cert_manager_letsencrypt" {
  pattern = "k8s/cert-manager/*.yaml"
  vars = {
    google_project      = google_container_cluster.default.project
    project_owner_email = var.project_owner_email
  }
}


resource "kubectl_manifest" "cert_manager_letsencrypt" {
  count     = length(data.kubectl_path_documents.cert_manager_letsencrypt.documents)
  yaml_body = element(data.kubectl_path_documents.cert_manager_letsencrypt.documents, count.index)

  depends_on = [ 
    time_sleep.cert_manager_webhook_ready,
    google_container_cluster.default,
    google_container_node_pool.primary
  ]
}


# add service-account annotations, so that it can impersonate the gke_dns service account that was created
resource "kubectl_manifest" "cert_manager_sa" {
  yaml_body     = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cert-manager
  namespace: "cert-manager"
  annotations:
    iam.gke.io/gcp-service-account: ${google_service_account.gke_dns.email}
  labels:
    app: cert-manager
    app.kubernetes.io/name: cert-manager
    app.kubernetes.io/instance: cert-manager
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: "controller"
    helm.sh/chart: cert-manager-v0.14.1
YAML
  depends_on = [
    time_sleep.cert_manager_webhook_ready
  ]
}


## external-dns
data "kubectl_file_documents" "external_dns" {
  content = file("k8s/external-dns/00-manifest.yaml")
}

resource "kubectl_manifest" "external_dns" {
  count     = length(data.kubectl_file_documents.external_dns.documents)
  yaml_body = element(data.kubectl_file_documents.external_dns.documents, count.index)
  
  depends_on = [ 
    google_container_cluster.default,
    google_container_node_pool.primary 
  ]
}

resource "kubectl_manifest" "external_dns_sa" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: external-dns
  annotations:
    iam.gke.io/gcp-service-account: ${google_service_account.gke_dns.email}
YAML

  depends_on = [
    kubectl_manifest.external_dns
  ]
}

## hipster demo
data "kubectl_path_documents" "hipster" {
  pattern = "k8s/hipster-demo/*.yaml"
  vars = {
    hipster_fqdn = local.hipster_fqdn
  }
}

resource "kubectl_manifest" "hipster" {
  count     = length(data.kubectl_path_documents.hipster.documents)
  yaml_body = element(data.kubectl_path_documents.hipster.documents, count.index)

  depends_on = [
    kubectl_manifest.external_dns,
    kubectl_manifest.cert_manager,
    google_container_cluster.default
  ]
}

output "hipster_demo_url" {
  value = "https://${local.hipster_fqdn}"
}
