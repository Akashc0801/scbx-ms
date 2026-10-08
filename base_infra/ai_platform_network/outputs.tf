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

output "private_dns_zones" {
  description = "Private DNS zone names and IDs keyed by zone key."
  value = {
    for key, zone in module.private_dns_zones : key => {
      name = zone.name
      id   = zone.resource_id
      virtual_network_links = {
        for link_key, link in zone.virtual_network_link_outputs : link_key => link.id
      }
    }
  }
}

output "public_ips" {
  description = "Public IP names, IDs, and addresses keyed by public IP key."
  value = {
    for key, public_ip in module.public_ips : key => {
      name       = public_ip.name
      id         = public_ip.resource_id
      ip_address = public_ip.public_ip_address
    }
  }
}

output "firewall_policies" {
  description = "Firewall policy names and IDs keyed by policy key."
  value = {
    for key, policy in module.firewall_policies : key => {
      name = policy.resource.name
      id   = policy.resource_id
    }
  }
}

output "firewalls" {
  description = "Firewall names and IDs keyed by firewall key."
  value = {
    for key, firewall in module.firewalls : key => {
      name = firewall.resource.name
      id   = firewall.resource_id
    }
  }
}

output "private_dns_resolvers" {
  description = "Private DNS resolver names, IDs, and inbound endpoint IPs keyed by resolver key."
  value = {
    for key, resolver in module.private_dns_resolvers : key => {
      name                 = resolver.name
      id                   = resolver.resource_id
      inbound_endpoint_ips = resolver.inbound_endpoint_ips
    }
  }
}

output "firewall_policy_rule_collection_groups" {
  description = "Firewall policy rule collection group names and IDs keyed by group key."
  value = {
    for key, group in module.firewall_policy_rule_collection_groups : key => {
      name = group.resource.name
      id   = group.resource_id
    }
  }
}
