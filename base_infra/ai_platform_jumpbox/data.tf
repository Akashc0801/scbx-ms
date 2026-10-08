# The Foundry VNet and its build subnet are created by
# base_infra/ai_platform_network and looked up by name.
data "azurerm_virtual_network" "foundry" {
  name                = var.network.virtual_network_name
  resource_group_name = var.network.virtual_network_resource_group_name
}

data "azurerm_subnet" "build" {
  name                 = var.network.build_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}
