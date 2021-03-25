variable "nos_functional_domain" {
    type = string
    description = "tbd"
}

variable "subscription_id" {
    type = string
    description = "the Azure subscription ID to use"
}

variable "env" {
    type = string
    description = "The environment. Possible values: [p|np|qa]"
}

variable "dns_zone" {
    type = string
}

variable "location" {
    type = string
    default = "North Europe"
}

variable "tags" {
    type = map(string)
    description = "All resources will have these tags"
    default = {
        terraform = "true"
    }
}

variable "resource_group" {
    type = string
    description = "resource group name"
}

variable "dns_parent_zone" {
    type = string
    description = "the name of the parent dns zone to register the record"
}

variable "dns_parent_zone_resource_group_name" {
    type = string
    description = "resource group name of the parent dns zone"
}

variable "dns_parent_zone_ns_record" {
    type = string
    description = "the name of the NS record"
}