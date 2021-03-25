## providers & terraform
terraform {
  required_version = ">= 0.14.0"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
  }
}

# random number provider - helps on naming some resources
resource "random_id" "rnd" {
  byte_length = 4
}

# random password generator
resource "random_password" "password" {
  length  = 16
  special = true
}


