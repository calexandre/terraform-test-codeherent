# More info: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#role_based_access_control
resource "azurerm_kubernetes_cluster" "default" {
  name                    = "${azurerm_resource_group.default.name}-aks"
  location                = azurerm_resource_group.default.location
  resource_group_name     = azurerm_resource_group.default.name
  dns_prefix              = azurerm_resource_group.default.name
  tags                    = var.tags
  private_cluster_enabled = false # Should this Kubernetes Cluster have its API server only exposed on internal IP addresses?

  lifecycle {
    ignore_changes = [
      # Ignore changes to node_count because enable_auto_scaling=true
      default_node_pool.0.node_count
    ]
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  default_node_pool {
    name                  = "default"
    node_count            = 2
    vm_size               = "Standard_B2MS"
    os_disk_size_gb       = 30
    vnet_subnet_id        = azurerm_subnet.default.id
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 6
    max_pods              = 64
    enable_node_public_ip = false
    # node_taints           = ["pool=build-pool:NoSchedule"]
    # node_labels = {
    #   node-pool = "build-pool"
    # }
    tags = {
      aks       = "${azurerm_resource_group.default.name}-aks"
      node-pool = "default"
      env       = "np"
    }
  }

  # supported addons: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#addon_profile
  #addon_profile { }

  auto_scaler_profile {

  }

  identity {
    type = "SystemAssigned"
  }
}

# Roles for letting AKS to update DNS using external-dns
#resource "azurerm_user_assigned_identity" "aks_default_user" {
#  name                = "${azurerm_kubernetes_cluster.default.name}-uai"
#  resource_group_name = azurerm_kubernetes_cluster.default.node_resource_group
#  location            = azurerm_kubernetes_cluster.default.location
#}

resource "azurerm_role_assignment" "dns_management" {
  scope                            = data.azurerm_subscription.this.id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
