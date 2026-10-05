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

- Messaging and Integration

## Notable changes in this version

### v1

- Initial version to deploy Event Hub namespace and event hubs with private endpoint, RBAC, and naming module integration.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys an Event Hub namespace and optionally creates event hubs, private endpoints, lock, and role assignments.
- It supports using an existing parent namespace for child event hub creation.
- Naming and mandatory tags are standardized through `mbb_naming_module`.

## Note

- Event Hub namespace networking and SKU settings should be aligned with throughput and security requirements.
- Namespace TLS is enforced with minimum TLS 1.2 in module implementation.

## Network Topology (wherever applicable)

- Hub/spoke with private endpoints and centralized private DNS is recommended for production workloads.

## Azure Service(s) in Scope

- Azure Event Hub Namespace
- Azure Event Hub
- Azure Private Endpoint

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Optional subnet/private DNS for private endpoint
- Optional existing Event Hub namespace (if using existing parent mode)

## Optional Azure services Used (Customer Choice)

- Log Analytics and diagnostics destinations
- Application Security Groups for private endpoint NIC association

## Limitations

- Some network rules and throughput options are SKU-dependent.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Event Hub namespace and optional child event hubs.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.0 |
| azapi | ~> 2.0 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_eventhub | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_eventhub) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "eventhub" {
  source = "../../modules/mbb_eventhub/v1.0.0.0"

  resource_group_name = var.resource_group_name

  sku         = "Standard"
  capacity    = 1
  event_hubs = {
    app1 = {
      namespace_name      = "placeholder"
      resource_group_name = var.resource_group_name
      partition_count     = 2
      message_retention   = 1
    }
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "evhns"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service
}
```

```tfvars
resource_group_name = "rg-integration"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where Event Hub resources are deployed | `string` | n/a | yes |
| sku | Event Hub namespace SKU | `string` | module-defined | no |
| capacity | Throughput capacity for namespace | `number` | `1` | no |
| auto_inflate_enabled | Enable auto-inflate | `bool` | `false` | no |
| maximum_throughput_units | Maximum throughput units when auto-inflate is enabled | `number` | `null` | no |
| public_network_access_enabled | Enable/disable public network access on namespace | `bool` | module-defined | no |
| network_rulesets | Namespace network rule set configuration | `object` | `null` | no |
| managed_identities | Namespace managed identity configuration | `object` | `{}` | no |
| existing_parent_resource | Existing namespace reference for child event hubs | `object` | `null` | no |
| event_hubs | Map of event hub definitions | `map(object)` | `{}` | no |
| private_endpoints | Map of private endpoint definitions | `map(object)` | `{}` | no |
| private_endpoints_manage_dns_zone_group | Manage private DNS zone groups in module | `bool` | `true` | no |
| lock | Optional management lock configuration | `object` | `null` | no |
| role_assignments | Map of namespace role assignments | `map(object)` | `{}` | no |
| diagnostic_settings | Map of diagnostic settings | `map(object)` | `{}` | no |
| enable_telemetry | Enable module telemetry | `bool` | `true` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_eventhub_namespace.this | resource |
| azurerm_eventhub.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_role_assignment.event_hubs | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint.this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| azurerm_management_lock.this | resource |
| modtm_telemetry.telemetry | resource |
| random_uuid.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| resource_id | Event Hub namespace resource ID |
| resource | Full Event Hub namespace resource output |
| resource_eventhubs | Map of event hub resources |
| private_endpoints | Map of private endpoints created |
