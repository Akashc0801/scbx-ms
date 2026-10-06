output "resource_groups" {
  description = "Resource group names and IDs keyed by resource group key."
  value = {
    for key, resource_group in module.resource_groups : key => {
      name = resource_group.name
      id   = resource_group.resource_id
    }
  }
}

output "virtual_networks" {
  description = "VNet names, IDs, address spaces, and subnet IDs keyed by VNet key."
  value = {
    for key, vnet in module.virtual_networks : key => {
      name          = vnet.name
      id            = vnet.resource_id
      address_space = var.virtual_networks[key].address_space
      subnets = {
        for subnet_key, subnet in vnet.subnets : subnet_key => {
          name = subnet.name
          id   = subnet.resource_id
        }
      }
    }
  }
}

output "network_security_groups" {
  description = "NSG names and IDs keyed by NSG key."
  value = {
    for key, nsg in module.network_security_groups : key => {
      name = nsg.name
      id   = nsg.resource_id
    }
  }
}

output "route_tables" {
  description = "Route table names and IDs keyed by route table key."
  value = {
    for key, route_table in module.route_tables : key => {
      name = route_table.name
      id   = route_table.resource_id
    }
  }
}
