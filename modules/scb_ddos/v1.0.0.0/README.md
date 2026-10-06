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

- Initial version to deploy Azure DDoS Protection Plan with naming, lock, and RBAC controls.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys one Azure DDoS Protection Plan with standardized naming and tagging via `scb_naming_module`.
- Optional management lock and role assignments are supported at DDoS plan scope.
- The module is suitable for centralized network security baselines where VNets are associated with a shared DDoS plan.

## Note

- Azure DDoS Protection Plan does not support diagnostic settings in this module.

## Network Topology (wherever applicable)

- Usually deployed centrally in a hub subscription/resource group and associated to spoke VNets as needed.

## Azure Service(s) in Scope

- Azure Network DDoS Protection Plan
- Azure Role Assignment
- Azure Management Lock

## Azure Services Needed (Pre-Requisites)

- Resource Group
- VNets (outside this module) that will consume the DDoS plan

## Optional Azure services Used (Customer Choice)

- Role-based access controls for operations teams

## Limitations

- Diagnostic settings are intentionally not part of this module.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Azure DDoS Protection Plan.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | >= 3.116, < 5.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_ddos | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_ddos) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "ddos" {
  source = "../../modules/scb_ddos/v1.0.0.0"

  resource_group_name = var.resource_group_name

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "ddos"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service

  role_assignments = {
    netops = {
      role_definition_id_or_name = "Reader"
      principal_id               = var.principal_id
    }
  }
}
```

```tfvars
resource_group_name = "rg-network-security"
principal_id        = "00000000-0000-0000-0000-000000000000"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where DDoS protection plan is deployed | `string` | n/a | yes |
| lock | Optional lock configuration (`CanNotDelete` or `ReadOnly`) | `object` | `null` | no |
| role_assignments | Map of role assignments on DDoS plan scope | `map(object)` | `{}` | no |
| enable_telemetry | Enable/disable module telemetry | `bool` | `true` | no |
| env | Naming module environment code | `string` | n/a | yes |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Naming module resource type code | `string` | `"ddos"` | no |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | n/a | yes |
| budget_id | Mandatory budget ID tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | `""` | no |
| criticality | Mandatory criticality tag | `string` | n/a | yes |
| environment | Mandatory environment tag | `string` | n/a | yes |
| service | Mandatory service tag value | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_network_ddos_protection_plan.this | resource |
| azurerm_management_lock.this | resource |
| azurerm_role_assignment.this | resource |
| modtm_telemetry.telemetry | resource |
| random_uuid.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| name | Name of DDoS protection plan |
| resource | Full DDoS protection plan resource |
| resource_id | Resource ID of DDoS protection plan |
