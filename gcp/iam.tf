
## Create a GCP service account (GSA) for Kubernetes workloads and save its email address.
## WARNING: Creation of service accounts is eventually consistent, and that can lead to errors 
##          when you try to apply ACLs to service accounts immediately after creation. 
##          If using these resources in the same config, you can add a sleep using local-exec.
##          More info at: https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "google_service_account" "gke_dns" {
  account_id   = "sa-gke-dns"
  display_name = "sa-gke-dns"
  description  = "Used by GKE workload identity to provide K8s workloads with the permissions it needs to manage DNS records"
}

## Bind gke_dns SA with DNS Admin role
resource "google_project_iam_binding" "gke_sa" {
  project = google_project.this.name
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.gke_dns.email}",
  ]
}

## Link the GSA to the Kubernetes service account (KSA) 
## This will allow GKE service account to impersonate the GSA to update the DNS
resource "google_service_account_iam_binding" "gsa_ksa" {
  service_account_id = google_service_account.gke_dns.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # form: <gke-identity-type>:<gke-identity-namespace>[k8s-namespace/k8s-service-account]
    "serviceAccount:${local.default_gke.workload_identity_config.identity_namespace}[external-dns/external-dns]",
    "serviceAccount:${local.default_gke.workload_identity_config.identity_namespace}[cert-manager/cert-manager]"
  ]
}

## This is a tweak to ensure that we wait 30 seconds after creating the above service account
## More info at: https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource "null_resource" "gke_sa_delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  triggers = {
    "before" = google_service_account.gke_dns.name
  }
}
