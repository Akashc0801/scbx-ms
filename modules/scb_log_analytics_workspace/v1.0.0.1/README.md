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

- Monitoring and Observability

## Notable changes in this version

### v1

- Version v1.0.0.1 of the module to deploy Azure Log Analytics Workspace with private endpoint, AMPLS integration, diagnostics, locks, and role assignments.
- Standardized metadata and operational tagging model aligned to enterprise controls.

## Upgrade Path

- Upgrade supported from v1.0.0.0 to v1.0.0.1.
- Update module source from modules/scb_log_analytics_workspace/v1.0.0.1 to modules/scb_log_analytics_workspace/v1.0.0.1.
- Input contract changes:
  - Added: experiment_phase, integration_id, last_vm_accessed, maintenance_window, os, patch_policy, retention, sandbox_type, service.
  - Removed: app_support, cost_allocation_unit, country, product_version.
- Resource/data model changes: none.
- Output changes: none.

# Product Description

## Overview

- This module deploys Azure Log Analytics Workspace with configurable retention, quotas, SKU, identity, and customer managed key settings.
- It supports private connectivity via private endpoints and monitor private link scope integration.
- It includes optional role assignments, diagnostics, and management lock controls.

## Note

- Public internet ingestion and query settings are exposed as inputs and default to false.
- Diagnostic settings map requires at least one destination per entry.

## Network Topology (wherever applicable)

- Designed for private ingestion and query patterns through private endpoint and AMPLS.
- Works in hub-and-spoke architectures with centralized monitoring controls.

## Azure Service(s) in Scope

- Azure Log Analytics Workspace
- Azure Monitor Private Link Scope
- Azure Private Endpoint
- Azure Monitor Diagnostic Settings
- Azure RBAC Role Assignments

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Subnet for private endpoint deployment
- Private DNS zones (if DNS zone group association is used)
- Principal IDs for RBAC role assignments

## Optional Azure services Used (Customer Choice)

- Log Analytics destination workspace for diagnostics
- Storage Account or Event Hub for diagnostic export

## Limitations

- Provider constraints in this version:
  - terraform ~> 1.5
  - azurerm >= 3.71, < 5.0.0
  - azapi ~> 2.0
  - modtm ~> 0.3
  - random ~> 3.5

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Log Analytics Workspace and optional private connectivity and governance components.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | ~> 1.5 |
| azurerm | >= 3.71, < 5.0.0 |
| azapi | ~> 2.0 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| scb_log_analytics_workspace | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_log_analytics_workspace) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "log_analytics_workspace" {
  source = "../../modules/scb_log_analytics_workspace/v1.0.0.1"

  name                = "law-platform-prod-sea-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_retention_in_days = 30

  private_endpoints = {
    pe1 = {
      subnet_resource_id            = var.private_endpoint_subnet_id
      private_dns_zone_resource_ids = [var.private_dns_zone_id]
    }
  }

  diagnostic_settings = {
    default = {
      workspace_resource_id = var.central_law_id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }

  role_assignments = {
    ops_reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = var.ops_group_object_id
    }
  }

  app_name            = var.app_name
  business_unit       = var.business_unit
  business_owner      = var.business_owner
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  criticality         = var.criticality
  environment         = var.environment
  data_classification = var.data_classification
  compliance          = var.compliance
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Log Analytics workspace name | string | n/a | yes |
| location | Deployment location | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| log_analytics_workspace_sku | Workspace SKU | string | null | no |
| log_analytics_workspace_retention_in_days | Data retention in days | number | null | no |
| log_analytics_workspace_daily_quota_gb | Daily ingestion quota (GB) | number | null | no |
| log_analytics_workspace_identity | Managed identity configuration | object | null | no |
| customer_managed_key | CMK configuration | object | null | no |
| private_endpoints | Private endpoint map | map(object) | {} | no |
| private_endpoints_manage_dns_zone_group | Manage private DNS zone group | bool | true | no |
| monitor_private_link_scope | AMPLS map | map(object) | {} | no |
| monitor_private_link_scoped_resource | AMPLS scoped resource map | map(object) | {} | no |
| monitor_private_link_scoped_service_name | AMPLS service name | string | null | no |
| diagnostic_settings | Diagnostic settings map | map(object) | {} | no |
| role_assignments | Role assignments map | map(object) | {} | no |
| lock | Management lock configuration | object | null | no |
| enable_telemetry | Enable AVM telemetry | bool | true | no |
| app_name | Mandatory business tag | string | n/a | yes |
| business_unit | Mandatory business tag | string | n/a | yes |
| business_owner | Mandatory business tag | string | n/a | yes |
| budget_id | Mandatory finance tag | string | n/a | yes |
| cost_center | Mandatory finance tag | string | "" | no |
| criticality | Mandatory operations tag | string | n/a | yes |
| environment | Mandatory operations tag | string | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_log_analytics_workspace.this | resource |
| azapi_resource.amplscope | resource |
| azurerm_monitor_private_link_scoped_service.this | resource |
| azapi_resource.ampls | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| azurerm_management_lock.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_role_assignment.this | resource |
| random_uuid.telemetry | resource |
| modtm_telemetry.telemetry | resource |
| azurerm_client_config.telemetry | data |
| modtm_module_source.telemetry | data |

### Outputs

| Name | Description |
|------|-------------|
| private_endpoints | Map of private endpoint resources |
| resource | Full Log Analytics workspace resource object |
| resource_id | Log Analytics workspace resource ID |
