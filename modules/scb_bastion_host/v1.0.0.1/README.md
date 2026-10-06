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

- Network Security

## Notable changes in this version

### v1

- `v1.0.0.1` bastion module alignment with `scb_naming_module` v1.0.0.1.
- Supports Standard, Basic, Premium, and Developer SKUs via AzAPI-based deployment.
- Includes integrated optional public IP deployment, lock, RBAC, diagnostics, and expanded tagging model.

## Upgrade Path

- Review SKU-specific behavior and input compatibility before moving from `v1.0.0.0` to `v1.0.0.1`, especially for Developer SKU and public IP handling.

# Product Description

## Overview

- This module deploys Azure Bastion Host with SCB naming and tagging standards.
- Standard/Basic/Premium SKUs are deployed with `azapi_resource.bastion`, while Developer SKU uses `azapi_resource.bastion_developer`.
- Optional public IP is provisioned through the `Azure/avm-res-network-publicipaddress/azurerm` module.

## Note

- Bastion requires dedicated `AzureBastionSubnet` subnet sizing and network controls based on Microsoft guidance.
- For private-only mode, ensure routing and DNS allow administrator access paths without public IP dependency.

## Network Topology (wherever applicable)

- Recommended in hub virtual network with controlled inbound management paths.
- Spoke resources are accessed through Bastion over private peering/transit connectivity.

## Azure Service(s) in Scope

- Azure Bastion Host
- Azure Public IP Address (optional)
- Azure Monitor Diagnostic Settings
- Azure Role Assignments

## Azure Services Needed (Pre-Requisites)

- Resource Group (resource ID input)
- Dedicated Bastion subnet (`AzureBastionSubnet`) for non-Developer SKUs
- Optional existing public IP if not created by module
- Optional monitoring destinations for diagnostics

## Optional Azure services Used (Customer Choice)

- Log Analytics Workspace
- Event Hub
- Storage Account

## Limitations

- Availability zone choices and scale units are validated by module constraints.
- Some features are SKU-dependent and may not apply to Developer SKU.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This Terraform module deploys one Azure Bastion Host with optional public IP, diagnostics, lock, and role assignments.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | >= 3.1.0, ~> 3.5 |
| time | >= 0.7.2 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_bastion_host | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_bastion_host) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "bastion" {
  source = "../../modules/scb_bastion_host/v1.0.0.1"

  resource_group_id = var.resource_group_id
  sku               = "Standard"

  ip_configuration = {
    subnet_id                      = var.bastion_subnet_id
    create_public_ip               = true
    public_ip_address_name         = "pip-bastion-prod-01"
    public_ip_merge_with_module_tags = true
  }

  copy_paste_enabled       = true
  file_copy_enabled        = false
  ip_connect_enabled       = false
  kerberos_enabled         = false
  private_only_enabled     = false
  session_recording_enabled = false
  shareable_link_enabled   = false
  tunneling_enabled        = true
  scale_units              = 2

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "bas"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  criticality         = var.criticality
  environment         = var.environment
  app_name            = var.app_name
  budget_id           = var.budget_id
  status              = "Active"
  service             = "Bastion"
}
```

```tfvars
resource_group_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-security"
bastion_subnet_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-security/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/AzureBastionSubnet"

env                 = "prod"
au                  = "0233985"
app_code            = "bastion"
bu                  = "it"
owner               = "platform"
business_owner      = "Security Operations"
business_unit       = "Infrastructure"
cost_center         = "CC001"
data_classification = "InfrastructureOnly"
compliance          = "ISO27001"
criticality         = "T1"
environment         = "Prod"
app_name            = "SCB-BastionHost"
budget_id           = "BUD001"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_id | Resource group ID where Bastion is deployed | `string` | n/a | yes |
| sku | Bastion SKU (`Basic`, `Standard`, `Premium`, `Developer`) | `string` | `"Standard"` | no |
| ip_configuration | Bastion IP configuration object (subnet, public IP behavior) | `object` | module-defined | no |
| zones | Availability zones used for Bastion/public IP | `list(string)` | `["1","2","3"]` | no |
| copy_paste_enabled | Enable copy/paste in Bastion sessions | `bool` | `true` | no |
| file_copy_enabled | Enable file copy capability | `bool` | `false` | no |
| ip_connect_enabled | Enable native IP connect feature | `bool` | `false` | no |
| kerberos_enabled | Enable Kerberos auth support | `bool` | `false` | no |
| private_only_enabled | Enable private-only bastion mode | `bool` | `false` | no |
| session_recording_enabled | Enable session recording | `bool` | `false` | no |
| shareable_link_enabled | Enable shareable session links | `bool` | `false` | no |
| tunneling_enabled | Enable Bastion tunneling | `bool` | `false` | no |
| scale_units | Scale units for supported SKUs | `number` | `2` | no |
| virtual_network_id | VNet ID for Developer SKU deployment | `string` | `null` | no |
| diagnostic_settings | Diagnostic settings map | `map(object)` | `{}` | no |
| role_assignments | Role assignments at Bastion/PIP scopes | `map(object)` | `{}` | no |
| lock | Optional management lock configuration | `object` | `null` | no |
| tags | Additional tags merged with naming module tags | `map(string)` | module-defined | no |
| env | Naming module environment code | `string` | n/a | yes |
| org | Naming module organization code | `string` | `null` | no |
| region_code | Naming module region code | `string` | `"myw"` | no |
| base_name | Naming module base name | `string` | `null` | no |
| additional_name | Naming module additional suffix | `string` | `null` | no |
| iterator | Naming module iterator | `string` | `"001"` | no |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Resource type code for generated naming | `string` | `"bas"` | no |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | n/a | yes |
| data_classification | Mandatory data classification tag | `string` | n/a | yes |
| compliance | Mandatory compliance tag | `string` | n/a | yes |
| criticality | Mandatory criticality tag | `string` | n/a | yes |
| environment | Mandatory environment tag | `string` | n/a | yes |
| app_name | Mandatory application name tag | `string` | n/a | yes |
| budget_id | Mandatory budget ID tag | `string` | n/a | yes |
| status | Mandatory status tag | `string` | n/a | yes |
| service | Mandatory service tag value | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azapi_resource.bastion | resource |
| azapi_resource.bastion_developer | resource |
| module.public_ip_address | module |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_role_assignment.pip | resource |
| azurerm_management_lock.this | resource |
| azurerm_management_lock.pip | resource |

### Outputs

| Name | Description |
|------|-------------|
| name | Generated Bastion resource name |
| resource | Bastion resource object (standard or developer path) |
| resource_id | Resource ID of Bastion |
| location | Deployment location from naming module |
| tags | Effective tags applied to Bastion |
| dns_name | Bastion DNS name |
| public_ip_address | Public IP module output when created |
