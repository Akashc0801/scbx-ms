[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span> |
| --- | --- |
| Version | 1 |
| Created By | Pooja Pradhan |
| Reviewed By | Amit Kumar |

# About this product version

## Product State: Released

## Product Category

- Networking

## Notable changes in this version

### v1

- Initial version to deploy Private DNS Resolver with inbound and outbound endpoints, forwarding rulesets, and forwarding rules.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys Azure Private DNS Resolver and optionally creates inbound endpoints, outbound endpoints, forwarding rulesets, forwarding rules, and virtual network links.
- It includes optional lock and RBAC assignment support for resolver and ruleset scope.
- Module telemetry is available and can be disabled.

## Note

- Existing virtual network and dedicated endpoint subnets are required.
- Outbound endpoint replacement is lifecycle-linked to forwarding rulesets through `terraform_data` to avoid stale bindings.

## Network Topology (wherever applicable)

- Hub-and-spoke deployment is recommended with resolver in hub VNet and linked spokes through forwarding rulesets.

## Azure Service(s) in Scope

- Azure Private DNS Resolver
- Inbound Endpoint
- Outbound Endpoint
- DNS Forwarding Ruleset and Forwarding Rule
- DNS Resolver Virtual Network Link

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Existing Virtual Network
- Existing resolver endpoint subnets

## Optional Azure services Used (Customer Choice)

- Additional spoke VNets linked to forwarding rulesets

## Limitations

- Endpoint subnets must follow Azure DNS Resolver subnet constraints.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Private DNS Resolver with optional inbound/outbound endpoints and DNS forwarding configuration.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.36 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | >= 3.5.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_dnsresolver | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_dnsresolver) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "dnsresolver" {
  source = "../../modules/scb_dnsresolver/v1.0.0.0"

  name                        = "dnspr-hub-sea-01"
  location                    = "southeastasia"
  resource_group_name         = var.resource_group_name
  virtual_network_resource_id = var.virtual_network_resource_id

  inbound_endpoints = {
    in1 = {
      subnet_name = "snet-dns-in"
    }
  }

  outbound_endpoints = {
    out1 = {
      subnet_name = "snet-dns-out"
      forwarding_ruleset = {
        corp = {
          rules = {
            corp_local = {
              domain_name = "corp.local."
              destination_ip_addresses = {
                "10.10.10.10" = "53"
              }
            }
          }
        }
      }
    }
  }
}
```

```tfvars
resource_group_name         = "rg-network-hub"
virtual_network_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | DNS resolver name | `string` | n/a | yes |
| location | Azure location for resolver resources | `string` | n/a | yes |
| resource_group_name | Resource group where resources are deployed | `string` | n/a | yes |
| virtual_network_resource_id | VNet resource ID containing resolver subnets | `string` | n/a | yes |
| inbound_endpoints | Map of inbound endpoint definitions | `map(object)` | `{}` | no |
| outbound_endpoints | Map of outbound endpoint definitions and forwarding config | `map(object)` | `{}` | no |
| lock | Optional management lock configuration | `object` | `null` | no |
| role_assignments | Map of role assignments for resolver scope | `map(object)` | `{}` | no |
| tags | Optional tags merged into resolver resources | `map(string)` | `null` | no |
| enable_telemetry | Enable module telemetry | `bool` | `true` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_private_dns_resolver.this | resource |
| azurerm_private_dns_resolver_inbound_endpoint.this | resource |
| azurerm_private_dns_resolver_outbound_endpoint.this | resource |
| terraform_data.outbound | resource |
| azurerm_private_dns_resolver_dns_forwarding_ruleset.this | resource |
| azurerm_private_dns_resolver_forwarding_rule.this | resource |
| azurerm_private_dns_resolver_virtual_network_link.default | resource |
| azurerm_private_dns_resolver_virtual_network_link.additional | resource |
| azurerm_management_lock.this | resource |
| azurerm_management_lock.rulesets | resource |
| azurerm_role_assignment.dnsresolver | resource |
| azurerm_role_assignment.rulesets | resource |

### Outputs

| Name | Description |
|------|-------------|
| name | DNS resolver name |
| resource | Full DNS resolver resource output |
| resource_id | DNS resolver resource ID |
| inbound_endpoints | Inbound endpoints map |
| inbound_endpoint_ips | Inbound endpoint IP addresses map |
| outbound_endpoints | Outbound endpoints map |
| forwarding_rulesets | Forwarding rulesets map |
