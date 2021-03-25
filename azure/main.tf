terraform {
  required_version = ">= 0.13.5"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.35.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_subscription" "this" {
}


resource "azurerm_resource_group" "default" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}
