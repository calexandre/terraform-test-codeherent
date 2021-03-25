## project related
variable "project_folder" {
  type        = string
  description = "The resource name of the Folder. Its format is folders/{folder_id}."
}

variable "project" {
  type        = string
  description = "The google project identifier to be created."
  validation {
    condition     = can(regex("^(.*)-(p|np)-(\\d{6})$", var.project))
    error_message = "The project must be in the following format: <name>-<p|np>-<6-random-digits> (ex: myproject-np-666777)."
  }
}

variable "project_owner_email" {
  type        = string
  description = "The email of the project owner."
  validation {
    condition     = can(regex("^([a-z0-9_\\.-]+\\@[\\da-z\\.-]+\\.[a-z\\.]{2,6})$", var.project_owner_email))
    error_message = "A valid email is required."
  }
}

variable "billing_account" {
  type        = string
  description = "The alphanumeric ID of the billing account this project belongs to."
}

variable "location" {
  default = "europe-west4"
}

variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list(string)
}

## globals (these are applied to every resource)
variable "env" {
  type        = string
  description = "The environment. Possible values: [p|np|qa]"
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the project."
  type        = map(string)
  default = {
    terraform = "true"
  }
}

## DNS stuff
variable "parent_dns_zone_name" {
  type = string
}

variable "parent_dns_zone_project" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "Project domain name. Used in the DNS registrations."
  validation {
    condition     = length(var.domain_name) > 0
    error_message = "A valid domain name is required."
  }
}
