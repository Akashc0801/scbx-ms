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

- Initial version to deploy Azure Firewall Policy with `scb_naming_module` v1.0.0.1 integration.
- Maintains existing firewall policy resource behavior from v1.0.0.0.
- Adds extended optional governance and operations tag inputs.

## Upgrade Path

- Upgrade supported from `v1.0.0.0` to `v1.0.0.1` with no planned state migration for resources.
- Update module source from `modules/scb_firewall_policy/v1.0.0.1` to `modules/scb_firewall_policy/v1.0.0.1`.
- Review variable changes and update tfvars:
  - New optional inputs: `automation_policy`, `backup_policy`, `experiment_phase`, `integration_id`, `last_vm_accessed`, `maintenance_window`, `os`, `patch_policy`, `retention`, `review_required`, `sandbox_type`, `service`.
  - Removed input: `country`.
- Remove obsolete `country` from variable files and pipeline templates.
- Run `terraform plan` and validate policy configuration and generated tags before `apply`.

# Product Description

## Overview

- This module deploys Azure Firewall Policy with enterprise naming and tag standards.
- It supports DNS, intrusion detection, explicit proxy, insights, TLS certificate, diagnostics, and RBAC blocks.
- It applies optional management locks and diagnostic settings based on input maps.

## Note

- Align threat intelligence, DNS proxy, and policy mode settings with security baseline requirements.
- Ensure dependent resources (Log Analytics, Key Vault, Event Hub) are prepared when relevant policy features are enabled.

## Network Topology (wherever applicable)

- Used as centralized policy object for one or more Azure Firewalls within secured hub-and-spoke or vWAN topologies.

## Azure Service(s) in Scope

- Azure Firewall Policy
- Azure Monitor Diagnostic Settings
- Azure RBAC Role Assignments

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Azure Firewall deployment target(s)
- Optional Log Analytics Workspace, Event Hub, Storage Account, Key Vault secret(s)

## Optional Azure services Used (Customer Choice)

- Log Analytics Workspace
- Event Hub
- Storage Account
- Key Vault

## Limitations

- Provider constraints follow current module compatibility (`azurerm >= 3.71, < 5.0.0`).
- Invalid combinations in advanced policy blocks may fail during plan/apply validation.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Azure Firewall Policy and optional attached governance/diagnostic artifacts.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | ~> 1.5 |
| azurerm | >= 3.71, < 5.0.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_firewall_policy | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_firewall_policy) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "scb_firewall_policy" {
  source = "../../modules/scb_firewall_policy/v1.0.0.1"

  resource_group_name                      = var.resource_group_name
  firewall_policy_threat_intelligence_mode = "Deny"
  firewall_policy_dns = {
    proxy_enabled = true
    servers       = ["10.0.0.4", "10.0.0.5"]
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "fwp"

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
| resource_group_name | Resource group for firewall policy deployment | `string` | n/a | yes |
| firewall_policy_dns | DNS policy configuration | `object` | `null` | no |
| firewall_policy_intrusion_detection | Intrusion detection policy block | `object` | `null` | no |
| firewall_policy_threat_intelligence_mode | Threat intelligence mode | `string` | `null` | no |
| firewall_policy_sku | Policy SKU tier | `string` | `null` | no |
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
| automation_policy | Optional automation policy tag | `string` | `""` | no |
| backup_policy | Optional backup policy tag | `string` | `""` | no |
| experiment_phase | Optional experimentation tag | `string` | `""` | no |
| integration_id | Optional integration tag | `string` | `""` | no |
| last_vm_accessed | Optional metadata tag | `string` | `""` | no |
| maintenance_window | Optional maintenance window tag | `string` | `""` | no |
| os | Optional OS tag | `string` | `""` | no |
| patch_policy | Optional patch policy tag | `string` | `""` | no |
| retention | Optional retention tag | `string` | `""` | no |
| review_required | Optional review flag tag | `string` | `""` | no |
| sandbox_type | Optional sandbox tag | `string` | `""` | no |
| service | Optional service tag | `string` | `""` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_firewall_policy.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_management_lock.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| resource | Full firewall policy resource object |
| resource_id | Firewall policy resource ID |
