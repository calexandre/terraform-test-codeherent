provider "google" {
  project = var.project
}

## project & folders specifics
# org is not needed if you use folders
# data "google_organization" "this" {
#   domain = var.project_org_domain
# }
data "google_billing_account" "this" {
  billing_account = var.billing_account
  open            = true
}

data "google_folder" "this" {
  folder = var.project_folder
}

# we need this for personal testing purposes
# it allows you to retrieve your current token to manage gcloud
data "google_client_config" "this" {}

resource "google_project" "this" {
  name            = var.project
  project_id      = var.project
  folder_id       = data.google_folder.this.name
  billing_account = data.google_billing_account.this.id
  lifecycle {
    prevent_destroy = false
  }
}

# Enable services in newly created GCP Project.
resource "google_project_service" "this" {
  count   = length(var.gcp_service_list)
  project = google_project.this.project_id
  service = var.gcp_service_list[count.index]
  # If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed. 
  # If false or unset, an error will be generated if any enabled services depend on this service when destroying it.
  disable_dependent_services = false
  # If true, disable the service when the terraform resource is destroyed. Defaults to true. 
  # May be useful in the event that a project is long-lived but the infrastructure running in that project changes frequently
  disable_on_destroy = false
}
