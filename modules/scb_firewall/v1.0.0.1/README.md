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

- Initial version to deploy Azure Firewall with `scb_naming_module` v1.0.0.1 integration.
- Maintains existing resource model and outputs from v1.0.0.0.
- Adds extended optional governance tag inputs for enterprise tagging.

## Upgrade Path

- Upgrade supported from `v1.0.0.0` to `v1.0.0.1` without resource recreation by default.
- Update module source from `modules/scb_firewall/v1.0.0.1` to `modules/scb_firewall/v1.0.0.1`.
- Review tag variable changes before apply:
  - New optional inputs: `additional_tags`, `auto_shutdown`, `experiment_phase`, `integration_id`, `last_vm_accessed`, `os`, `retention`, `review_required`, `sandbox_type`, `service`.
  - Removed input: `country`.
- If `country` was used in `tfvars`, remove it before planning.
- Run `terraform plan` and validate tag outputs and policy associations before `apply`.

# Product Description

## Overview

- This module deploys an Azure Firewall resource using standardized naming and tags.
- It supports both VNet and Virtual Hub firewall patterns and policy attachment.
- It supports role assignments, diagnostic settings, and management lock configuration.

## Note

- Firewall policy attached through `firewall_policy_id` must satisfy organization security requirements.
- Ensure required subnet and public IP dependencies are provisioned before deploying firewall configurations.

## Network Topology (wherever applicable)

- Deployed inside an Azure virtual network or virtual hub architecture, based on input configuration.

## Azure Service(s) in Scope

- Azure Firewall
- Azure Monitor Diagnostic Settings
- Azure RBAC Role Assignments

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Virtual Network and subnet (for VNet mode) and/or Virtual Hub (for hub mode)
- Firewall Policy
- Public IP resources based on selected deployment mode

## Optional Azure services Used (Customer Choice)

- Log Analytics Workspace
- Event Hub
- Storage Account

## Limitations

- Module depends on naming/tagging interface exposed by `scb_naming_module` v1.0.0.1.
- `firewall_ip_configuration` is deprecated; use `ip_configurations`.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Azure Firewall and optional dependent configuration objects.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | ~> 1.7 |
| azurerm | >= 3.71, < 5.0.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_firewall | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_firewall) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "scb_firewall" {
  source = "../../modules/scb_firewall/v1.0.0.1"

  resource_group_name = var.resource_group_name
  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = "Premium"
  firewall_policy_id  = var.firewall_policy_id

  ip_configurations = {
    primary = {
      name                 = "ipconfig1"
      subnet_id            = var.azure_firewall_subnet_id
      public_ip_address_id = var.public_ip_id
    }
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "afw"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group for firewall deployment | `string` | n/a | yes |
| firewall_sku_name | Firewall SKU name (`AZFW_Hub` or `AZFW_VNet`) | `string` | n/a | yes |
| firewall_sku_tier | Firewall SKU tier (`Premium`, `Standard`, `Basic`) | `string` | n/a | yes |
| firewall_policy_id | Firewall policy resource ID | `string` | n/a | yes |
| ip_configurations | Firewall IP configurations map | `map(object)` | `{}` | no |
| firewall_virtual_hub | Virtual hub deployment block | `object` | `null` | no |
| diagnostic_settings | Diagnostic settings map | `map(object)` | `{}` | no |
| role_assignments | Role assignments map | `map(object)` | `{}` | no |
| lock | Management lock configuration | `object` | `null` | no |
| env | Naming module environment code | `string` | n/a | yes |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner | `string` | n/a | yes |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | `"DefaultBusinessUnit"` | no |
| cost_center | Mandatory cost center tag | `string` | `""` | no |
| data_classification | Data classification tag | `string` | `""` | no |
| compliance | Compliance tag | `string` | `"None"` | no |
| criticality | Criticality tag | `string` | n/a | yes |
| environment | Environment tag value | `string` | n/a | yes |
| additional_tags | Additional custom tags | `map(string)` | `null` | no |
| auto_shutdown | Optional operational tag | `string` | `""` | no |
| experiment_phase | Optional experimentation tag | `string` | `""` | no |
| integration_id | Optional integration tag | `string` | `""` | no |
| last_vm_accessed | Optional metadata tag | `string` | `""` | no |
| os | Optional OS tag | `string` | `""` | no |
| retention | Optional retention tag | `string` | `""` | no |
| review_required | Optional governance review tag | `string` | `""` | no |
| sandbox_type | Optional sandbox tag | `string` | `""` | no |
| service | Optional service tag | `string` | `""` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_firewall.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_management_lock.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| resource | Full firewall resource object |
| resource_id | Firewall resource ID |
