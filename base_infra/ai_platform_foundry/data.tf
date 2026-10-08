data "azurerm_client_config" "current" {}

# The resource group, VNet, subnets and private DNS zones are created by
# base_infra/ai_platform_network. They are looked up by name so the two stacks
# keep separate state.
data "azurerm_resource_group" "foundry" {
  name = var.network.resource_group_name
}

data "azurerm_subnet" "agent" {
  name                 = var.network.agent_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  name                 = var.network.private_endpoint_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zone_names

  name                = each.value
  resource_group_name = var.network.private_dns_zone_resource_group_name
}

# azurerm_subnet does not expose delegations; read them for the preflight check.
data "azapi_resource" "agent_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  resource_id = data.azurerm_subnet.agent.id

  response_export_values = ["properties.delegations"]
}
