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

- Monitoring and Alerting

## Notable changes in this version

### v1

- Initial version to deploy Azure Monitor Action Group with standardized naming and mandatory enterprise tagging.
- Supports receiver configurations for email, sms, voice, webhook, ARM role, automation runbook, Azure Function, Logic App, Event Hub, ITSM, and Azure App Push.

## Upgrade Path

- This is the initial release (v1.0.0.0).
- No prior module version exists for in-place upgrade.

# Product Description

## Overview

- This module deploys Azure Monitor Action Group using azurerm_monitor_action_group.
- Resource name and tags are generated through scb_naming_module.
- The module supports dynamic receiver blocks for all major Azure Monitor action group receiver types.

## Note

- Action Group location is set to global in this module implementation.
- short_name must be 12 characters or fewer.

## Network Topology (wherever applicable)

- Not network-topology specific. This module configures notification and automation endpoints for alerting workflows.

## Azure Service(s) in Scope

- Azure Monitor Action Group
- Azure Monitor Alerts integration endpoints

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Alert rules or monitoring workflows that reference the action group
- Endpoint targets (email, webhook, logic apps, functions, etc.) as required by selected receiver types

## Optional Azure services Used (Customer Choice)

- Azure Logic Apps
- Azure Functions
- Azure Automation
- Azure Event Hub
- ITSM connectors

## Limitations

- Provider constraints in this version:
  - terraform >= 1.9, < 2.0
  - azurerm ~> 4.36
  - azapi ~> 2.4
  - modtm ~> 0.3
  - random >= 3.5.0

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Azure Monitor Action Group with optional receiver lists.

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
| scb_monitor_action_group | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_monitor_action_group) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "monitor_action_group" {
  source = "../../modules/scb_monitor_action_group/v1.0.0.0"

  resource_group_name = var.resource_group_name
  short_name          = "opsalerts"

  env                = var.env
  au                 = var.au
  owner              = var.owner
  app_code           = var.app_code
  bu                 = var.bu
  environment        = var.environment
  business_owner     = var.business_owner
  business_unit      = var.business_unit
  criticality        = var.criticality
  cost_center        = var.cost_center
  data_classification = var.data_classification
  compliance         = var.compliance

  email_receivers = [
    {
      name          = "OpsTeam"
      email_address = "ops@example.com"
    }
  ]

  webhook_receivers = [
    {
      name        = "IncidentWebhook"
      service_uri = "https://example.org/alerts"
    }
  ]
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where action group is created | string | n/a | yes |
| short_name | Short name for action group (max 12 chars) | string | n/a | yes |
| enabled | Whether action group is enabled | bool | true | no |
| email_receivers | List of email receiver objects | list(object) | null | no |
| sms_receivers | List of sms receiver objects | list(object) | null | no |
| voice_receivers | List of voice receiver objects | list(object) | null | no |
| webhook_receivers | List of webhook receiver objects (optional aad_auth) | list(object) | null | no |
| arm_role_receivers | List of ARM role receiver objects | list(object) | null | no |
| automation_runbook_receivers | List of automation runbook receiver objects | list(object) | null | no |
| azure_app_push_receivers | List of Azure app push receiver objects | list(object) | null | no |
| azure_function_receivers | List of Azure function receiver objects | list(object) | null | no |
| event_hub_receivers | List of Event Hub receiver objects | list(object) | null | no |
| itsm_receivers | List of ITSM receiver objects | list(object) | null | no |
| logic_app_receivers | List of Logic App receiver objects | list(object) | null | no |
| env | Naming module environment code | string | n/a | yes |
| au | Naming module accounting unit code | string | n/a | yes |
| owner | Naming module owner code | string | n/a | yes |
| app_code | Naming module application code | string | n/a | yes |
| bu | Naming module business unit code | string | n/a | yes |
| environment | Mandatory governance tag | string | n/a | yes |
| business_owner | Mandatory governance tag | string | n/a | yes |
| business_unit | Mandatory governance tag | string | n/a | yes |
| criticality | Mandatory governance tag | string | n/a | yes |
| cost_center | Mandatory finance tag | string | n/a | yes |
| data_classification | Mandatory governance tag | string | n/a | yes |
| compliance | Mandatory governance tag | string | n/a | yes |

### Resources

| Name | Type |
|------|------|
| module.scb_module_mag | module |
| azurerm_monitor_action_group.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| id | Action Group resource ID |
| name | Action Group name |
| resource_group_name | Resource group name |
| short_name | Configured short name |
| enabled | Action group enabled state |
| action_group | Full action group resource object |
