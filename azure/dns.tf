resource "azurerm_dns_zone" "default" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.default.name
  tags                = var.tags
}

# parent zone
data "azurerm_dns_zone" "parent" {
  name                = var.dns_parent_zone
  resource_group_name = var.dns_parent_zone_resource_group_name
}

# parent zone - NS records for the child zone
resource "azurerm_dns_ns_record" "this" {
  name                = var.dns_parent_zone_ns_record
  zone_name           = data.azurerm_dns_zone.parent.name
  resource_group_name = data.azurerm_dns_zone.parent.resource_group_name
  ttl                 = 3600
  tags                = var.tags

  records = azurerm_dns_zone.default.name_servers
}