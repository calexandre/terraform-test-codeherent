## DNS management
locals {
  fqdn = "${var.domain_name}.${data.google_dns_managed_zone.parent.dns_name}"
}

## parent zone configuration - we need this to setup delegation for the zone we are creating for this project
data "google_dns_managed_zone" "parent" {
  name    = var.parent_dns_zone_name
  project = var.parent_dns_zone_project
}

# parent zone - NS records for the child zone
# gcloud dns record-sets list -z cloud-demo-zone --project poc-anthos-on-prem
resource "google_dns_record_set" "parent_ns" {
  name         = local.fqdn
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.this.name_servers

  managed_zone = data.google_dns_managed_zone.parent.name
  project      = data.google_dns_managed_zone.parent.project
}

# this is the zone that will be associated with this project
resource "google_dns_managed_zone" "this" {
  name     = "dns-${var.domain_name}"
  dns_name = local.fqdn

  # Set this true to delete all records in the zone.
  force_destroy = true

  labels     = var.labels
  depends_on = [google_project_service.this]
}
