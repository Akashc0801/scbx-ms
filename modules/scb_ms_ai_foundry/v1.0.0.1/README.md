# scb_ms_ai_foundry

## Product State: Released

## Product Category

- AI Platform

## Notable changes in this version

### v1.0.0.1 (updated 2026-10-08)

- Diagnostic settings on the Foundry account (`ai_foundry_accounts[*].diagnostic_settings`).
- Management lock on the Foundry account (`ai_foundry_accounts[*].lock`).
- Corrected `ProductName` and `ProductVersion` tags.
- Fixed connections that carry credentials (sensitive `for_each`) and role assignments with an empty description.
- Set `resource_type_code = "aif"` and `max_length = 64` when calling the module; the defaults (`kv`, 24) do not suit a Foundry account.

## Upgrade Path

- Not deployed before these changes; no upgrade path needed.

# Product Description

## Overview

Deploys Microsoft Foundry (`Microsoft.CognitiveServices/accounts`, kind `AIServices`) with projects, model deployments, content filter (RAI) policies, account and project connections, capability hosts for standard agent setup, private endpoints and RBAC. Account names and tags come from `scb_naming_module/v1.0.0.1`.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azapi | ~> 2.0 |
| azurerm | ~> 4.0 |
| time | ~> 0.9 |

## How to use this product in Terraform

```hcl
module "foundry" {
  source = "../../modules/scb_ms_ai_foundry/v1.0.0.1"

  ai_foundry_accounts = {
    shared = {
      parent_id              = var.resource_group_id
      sku_name               = "S0"
      identity_type          = "UserAssigned"
      identity_id            = var.foundry_uami_id
      disableLocalAuth       = true
      allowProjectManagement = true
      customSubDomainName    = var.custom_subdomain
      publicNetworkAccess    = "Disabled"

      network_injections = [{
        scenario      = "agent"
        subnet_arm_id = var.agent_subnet_id
      }]

      diagnostic_settings = {
        operations = {
          workspace_resource_id = var.operations_law_id
        }
      }

      lock = {
        kind = "CanNotDelete"
      }
    }
  }

  # naming and tag inputs (env, au, owner, app_code, bu, app_name, business_unit,
  # business_owner, budget_id, criticality, environment, service, ...) as per scb_naming_module
}
```

## Terraform Module Documentation

### Account inputs added 2026-10-08 (inside each `ai_foundry_accounts` entry)

| Name | Description | Type | Default |
|------|-------------|------|---------|
| diagnostic_settings | Map of diagnostic settings. Each entry needs at least one of `workspace_resource_id`, `storage_account_resource_id`, `event_hub_authorization_rule_resource_id`, `marketplace_partner_resource_id`. Defaults: `log_groups = ["allLogs"]`, `metric_categories = ["AllMetrics"]`, `log_analytics_destination_type = "Dedicated"`. | `map(object)` | `{}` |
| lock | `{ kind = "CanNotDelete" \| "ReadOnly", name = optional(string) }` | `object` | `null` |

### Resources added 2026-10-08

| Name | Type |
|------|------|
| azurerm_monitor_diagnostic_setting.ai_foundry_account | resource |
| azurerm_management_lock.ai_foundry_account | resource |

### Outputs

| Name | Description |
|------|-------------|
| ai_foundry_account_ids | Map of account IDs |
| ai_foundry_project_ids | Map of project IDs |
| ai_foundry_deployment_ids | Map of model deployment IDs |
| ai_foundry_project_connection_ids | Map of project connection IDs |
| account_connection_ids | Map of account connection IDs |
| project_internal_ids | Map of project internal IDs (for ABAC conditions) |
| rai_policy_name / rai_policy_id | Content filter policy names and IDs |
| ai_foundry_project_diagnostic_setting_ids | Map of project diagnostic setting IDs |
| ai_foundry_account_diagnostic_setting_ids | Map of account diagnostic setting IDs (new) |
| ai_foundry_account_lock_ids | Map of account lock IDs (new) |

## Testing

```bash
terraform init -backend=false
terraform test
```
