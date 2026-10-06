[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.1 |
| Created By | Sonali Wadhwa |
| Reviewed By|  |

# About this product version

## Product State: Released

## Product Category

- Container App

## Notable changes in this version

### v1.0.0.1

- This module deploys an Azure Container App with optional Container App Environment creation, ingress, Dapr, scaling rules, managed identities, management lock, and role assignments.

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- This module deploys an Azure Container App with optional Container App Environment creation, ingress, Dapr, scaling rules, managed identities, management lock, and role assignments.


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure Container App

## Azure Services Needed (Pre-Requisites)

- Resource Group

## Optional Azure services Used (Customer Choice)

- None

## Limitations

- None

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one `Azure Container App and Container App Environment(Optional)`.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |



### Azure Artifacts

| Name | Source | Version |
|------|--------|---------|
| Container App | [scb_container_app](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_container_app/v1.0.0.1) | 1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

# SCB Container App Module

This module deploys an [Azure Container App](https://learn.microsoft.com/en-us/azure/container-apps/overview) with optional Container App Environment creation, ingress, Dapr, scaling rules, managed identities, management lock, and role assignments.

It follows the [Azure Verified Module (AVM)](https://aka.ms/avm) conventions and uses the **scb\_naming\_module** for consistent resource naming and tagging.

## Features

- Create or reference an existing **Container App Environment**
- Configurable **containers** and **init containers** with health probes (liveness, readiness, startup) and volume mounts
- **Ingress** with traffic weight splitting, custom domains, CORS policy, and IP security restrictions
- **Dapr** sidecar integration
- **Container registries** (managed identity or username/password)
- **Secrets** (inline values or Key Vault references)
- **Scaling rules**: HTTP, TCP, Azure Queue, and custom (KEDA)
- **Managed identities** (system-assigned, user-assigned, or both)
- **Management lock** (CanNotDelete / ReadOnly)
- **Role assignments** on the Container App resource
- **Workload profiles** on the Container App Environment

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 3.117, < 5.0 |
| random | ~> 3.5 |
| time | ~> 0.9 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.ca_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_container_app_environment.ace_existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment) | data source |

## Module Dependencies

| Name | Source |
|------|--------|
| scb\_module\_ca | `../../scb_naming_module/v1.0.0.1` |

<!-- markdownlint-disable MD013 -->
## Required Inputs

### Naming Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `env` | Environment code (e.g. `test`). | `string` | n/a |
| `au` | Accounting Unit (AU) code. Must be numeric. | `string` | n/a |
| `owner` | Technology owner group. | `string` | n/a |
| `product_version` | Product version (e.g. `1.0.0`). | `string` | n/a |
| `app_code` | Application code (e.g. `network`, `mgmt`). | `string` | n/a |
| `bu` | Business unit code (e.g. `IT`, `scb`). | `string` | n/a |

### Mandatory Business Tags

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `app_name` | Human-readable name for the application. | `string` | n/a |
| `app_support` | Email address of the support team. | `string` | n/a |
| `business_unit` | Department that owns the resources. | `string` | n/a |
| `business_owner` | Contact name of the application owner. | `string` | n/a |
| `budget_id` | Budget or GL code used by Finance. | `string` | n/a |
| `criticality` | Workload SLA requirements. | `string` | n/a |
| `environment` | Environment where the resource is located. | `string` | n/a |

### Container App Environment

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `container_app_environment_name` | The name of the Container App Environment (existing or new). | `string` | n/a |

### Container App

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `resource_group_name` | The resource group for the Container App. | `string` | n/a |
| `template` | Template block defining containers, init containers, scaling rules, and volumes. | `object(...)` | n/a |

## Optional Inputs

### Naming Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `resource_type_code` | Azure resource type abbreviation. | `string` | `"ca"` |
| `org` | Company/business unit code. | `string` | `"scb"` |
| `region_code` | Region code. Must be one of `ea`, `sea`, `eu`, `myw`, `sg`, `idc`. | `string` | `"sea"` |
| `additional_name` | Additional suffix for resource uniqueness. | `string` | `null` |
| `iterator` | Iterator for resource uniqueness. | `string` | `null` |
| `base_name` | Application/infrastructure base name. | `string` | `null` |
| `max_length` | Maximum length of the generated name. | `number` | `63` |
| `no_dashes` | Remove all `-` separators from the generated name. | `bool` | `false` |
| `add_random` | Add a random number at the name's end. | `bool` | `false` |
| `rnd_length` | Length of the random number generated. | `number` | `2` |
| `additional_tags` | Additional base tags. | `map(string)` | `null` |

### Container App Environment

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_container_app_environment` | Whether to create a new Container App Environment. | `bool` | `false` |
| `existing_container_app_environment_resourcegroup_name` | Resource group of the existing Container App Environment (required when `create_container_app_environment = false`). | `string` | `null` |
| `container_app_environment_dapr_application_insights_connection_string` | Application Insights connection string for Dapr telemetry. | `string` | `null` |
| `container_app_environment_infrastructure_resource_group_name` | Platform-managed resource group for infrastructure resources. | `string` | `null` |
| `container_app_environment_infrastructure_subnet_id` | Subnet for the Container Apps Control Plane (`/21` or larger). | `string` | `null` |
| `container_app_environment_internal_load_balancer_enabled` | Enable Internal Load Balancing mode. | `bool` | `false` |
| `container_app_environment_log_analytics_workspace_id` | Log Analytics workspace ID (required when `logs_destination = "log-analytics"`). | `string` | `null` |
| `container_app_environment_logs_destination` | Where to save application logs (`log-analytics` or `azure-monitor`). | `string` | `null` |
| `container_app_environment_mutual_tls_enabled` | Enable mutual TLS. | `bool` | `false` |
| `container_app_environment_public_network_access` | Public network access (`Enabled` or `Disabled`). | `string` | `null` |
| `container_app_environment_zone_redundancy_enabled` | Enable Zone Redundancy. | `bool` | `false` |
| `container_app_environment_workload_profiles` | Workload profiles for the environment. | `list(object(...))` | `null` |
| `container_app_environment_identity` | Managed identity for the environment. | `object(...)` | `null` |

### Container App

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `revision_mode` | Revisions operational mode (`Single` or `Multiple`). | `string` | `"Single"` |
| `workload_profile_name` | Workload profile name to pin for execution. | `string` | `null` |
| `max_inactive_revisions` | Max inactive revisions a Container App can have. | `number` | `null` |
| `ingress` | Ingress configuration (target port, traffic weight, custom domains, CORS, IP restrictions). | `object(...)` | `null` |
| `dapr` | Dapr sidecar configuration. | `object(...)` | `null` |
| `registries` | Container registry configuration for pulling images. | `list(object(...))` | `null` |
| `secrets` | Secret configuration (inline or Key Vault references). | `list(object(...))` | `null` |
| `managed_identities` | System and/or user-assigned managed identity configuration. | `object(...)` | `{}` |
| `lock` | Resource lock configuration (`CanNotDelete` or `ReadOnly`). | `object(...)` | `null` |
| `role_assignments` | Map of role assignments on the Container App. | `map(object(...))` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the Container App. |
| `resource_id` | The Azure resource ID of the Container App. |
| `identity` | The identities assigned to the Container App. |
| `latest_revision_name` | The name of the latest revision. |
| `latest_revision_fqdn` | The FQDN of the latest revision. |
| `location` | The Azure region of the Container App. |
| `outbound_ip_addresses` | The outbound IP addresses. |
| `custom_domain_verification_id` | The custom domain verification ID. |
| `container_app_environment_id` | The ID of the Container App Environment (created or existing). |
| `container_app_environment_default_domain` | The default domain of the created Container App Environment. |
| `container_app_environment_static_ip_address` | The static IP address of the created Container App Environment. |

## Usage

### Basic — Single Container App with new environment

```hcl
module "container_app" {
  source = "../../scb_container_app/v1.0.0.1"

  # Naming
  env                = "test"
  au                 = "0233985"
  app_code           = "myapp"
  bu                 = "gcto"
  owner              = "Cloud Engineering"
  region_code        = "sea"
  product_version    = "1.0"
  base_name          = "api"
  iterator           = "001"

  # Mandatory Tags
  business_unit  = "Group Technology"
  business_owner = "John Doe"
  app_name       = "My Container App"
  app_support    = "support@example.com"
  budget_id      = "BUD-001"
  criticality    = "High"
  environment    = "test"

  # Resource Group
  resource_group_name = "rg-scb-containerapp-test"

  # Create a new Container App Environment
  create_container_app_environment                     = true
  container_app_environment_name                       = "cae-scb-api-test"
  container_app_environment_logs_destination           = "log-analytics"
  container_app_environment_log_analytics_workspace_id = "/subscriptions/.../workspaces/law-xxx"

  # Container App Template
  template = {
    min_replicas = 1
    max_replicas = 5
    containers = [
      {
        name   = "api-container"
        image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
        cpu    = 0.5
        memory = "1Gi"
        env = [
          {
            name  = "ENVIRONMENT"
            value = "test"
          }
        ]
      }
    ]
  }

  # Ingress
  ingress = {
    external_enabled = true
    target_port      = 80
    traffic_weight = [
      {
        latest_revision = true
        percentage      = 100
      }
    ]
  }

  # Identity
  managed_identities = {
    system_assigned = true
  }
}
```

### Using an existing Container App Environment

```hcl
module "container_app_worker" {
  source = "../../scb_container_app/v1.0.0.1"

  # ... naming and tag variables ...

  resource_group_name = "rg-scb-containerapp-test"

  # Reference an existing environment
  create_container_app_environment                    = false
  container_app_environment_name                      = "cae-scb-api-test"
  existing_container_app_environment_resourcegroup_name = "rg-scb-containerapp-test"

  template = {
    min_replicas = 0
    max_replicas = 3
    containers = [
      {
        name   = "worker-container"
        image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
        cpu    = 0.25
        memory = "0.5Gi"
      }
    ]
    custom_scale_rule = [
      {
        name             = "queue-scaler"
        custom_rule_type = "azure-queue"
        metadata = {
          queueName   = "work-items"
          queueLength = "5"
        }
      }
    ]
  }
}
```

### Multiple Container Apps with `for_each`

See the [examples/](./examples/) directory for a complete working example that deploys multiple container apps using a `for_each` pattern with `variables.tf` and `terraform.tfvars`.

## File Structure

```
v1.0.0.1/
├── data.tf           # Data source for existing Container App Environment
├── locals.tf         # Identity type computation
├── main.tf           # Container App resource, lock, role assignments
├── main.ace.tf       # Container App Environment resource
├── outputs.tf        # Module outputs
├── terraform.tf      # Provider requirements
├── variables.tf      # All input variables
├── README.md
└── examples/
    ├── main.tf           # Example calling code with for_each
    ├── variables.tf      # Variable definitions for the example
    └── terraform.tfvars  # Sample values
```

### Outputs

| Name | Description |
|------|-------------|
| name | The name of the Container App |
| resource_id |   description = "The Azure resource ID of the Container App |
| identity | The identities assigned to the Container App |
| container_app_environment_id | The ID of the Container App Environment |
| container_app_environment_default_domain| The default domain of the Container App Environment |
| container_app_environment_static_ip_address | The Static IP address of the Container App Environment |

<!-- END_TF_DOCS -->
