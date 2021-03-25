# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
# }
output "tenant_id" {
  value = data.azurerm_subscription.this.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.this.subscription_id
}

output "resource_group" {
  value = var.resource_group
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
}

output "aks_default_managed_identity_client_id" {
  description = "The Client ID of the user-defined Managed Identity assigned to the Kubelets"
  value       = azurerm_kubernetes_cluster.default.kubelet_identity[0].client_id
}

output "aks_default_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "dns_zone_ns_records" {
  description = "A list of values that make up the NS record for the zone."
  value       = azurerm_dns_zone.default.name_servers
}
