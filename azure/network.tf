resource "azurerm_network_security_group" "default" {
  name                = "${azurerm_resource_group.default.name}-nsg-default"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  tags                = var.tags
}

resource "azurerm_virtual_network" "default" {
  name                = "${azurerm_resource_group.default.name}-vnet-default"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  tags                = var.tags

  address_space = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "default" {
  name                 = "${azurerm_resource_group.default.name}-subnet-default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.1.1.0/25"]
}
