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

- Integration

## Notable changes in this version

### v1

- Initial version to deploy Azure API Management (`mbb_apim`).

## Upgrade Path

- Not available as this is the initial documentation version.

# Product Description

## Overview

- This Terraform module deploys and configures Azure API Management (APIM).
- It supports APIM service deployment, APIs, API operations, API policies, version sets, products, named values, subscriptions, diagnostics, RBAC, and private endpoints.
- It also supports APIM security/network options including custom hostname configuration, VNet integration, and service-level policy configuration.

## Note

- APIM publisher email (`publisher_email`) is mandatory and must be a valid email format.
- For internal/private APIM deployments, ensure subnet and Private DNS strategy are pre-approved and ready.

## Network Topology (wherever applicable)

- Hub/spoke with shared services (DNS, Firewall, monitoring) is recommended.
- Private endpoint based connectivity is supported for enterprise private access patterns.

## Azure Service(s) in Scope

- Azure API Management
- Private Endpoint
- Azure Monitor Diagnostic Settings

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Virtual Network/Subnet (if using APIM in Internal/External VNet mode)
- Log Analytics Workspace (if diagnostic settings are enabled)

## Optional Azure services Used (Customer Choice)

- Azure Key Vault (for certificates and named value secrets)
- Event Hub / Storage Account (diagnostic log destinations)

## Limitations

- Availability Zones are supported only for Premium SKU.
- `virtual_network_subnet_id` must not be set when `virtual_network_type = "None"`.
- Some advanced APIM capabilities depend on selected SKU and region support.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This module creates one APIM instance and optionally configures related APIM entities (APIs, products, named values, subscriptions, and policies).

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 4.0, < 5.0 |
| azapi | ~> 2.4 |
| modtm | >= 0.3, < 1.0 |
| random | >= 3.5, < 4.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_apim | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_apim) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "apim" {
  source = "../../modules/mbb_apim/v1.0.0.0"

  # APIM required parameters
  location            = var.location
  name                = var.name
  publisher_email     = var.publisher_email
  resource_group_name = var.resource_group_name

  # APIM optional core parameters
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name
  virtual_network_type = var.virtual_network_type
  virtual_network_subnet_id = var.virtual_network_subnet_id

  # Optional APIM artifacts
  api_version_sets    = var.api_version_sets
  apis                = var.apis
  products            = var.products
  named_values        = var.named_values
  subscriptions       = var.subscriptions
  service_policy      = var.service_policy
  diagnostic_settings = var.diagnostic_settings
  private_endpoints   = var.private_endpoints

  # Naming module required variables
  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  business_owner     = var.business_owner
  resource_type_code = "apim"

  tags = var.tags
}
```

```tfvars
location            = "southeastasia"
name                = "apim-mybk-sea-001"
publisher_email     = "apim.owner@maybank.com"
publisher_name      = "Maybank API Platform"
resource_group_name = "rg-apim-sea-001"
sku_name            = "Developer_1"

virtual_network_type      = "None"
virtual_network_subnet_id = null

api_version_sets = {}
apis             = {}
products         = {}
named_values     = {}
subscriptions    = {}

service_policy = null
diagnostic_settings = {}
private_endpoints   = {}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region where APIM is deployed | `string` | n/a | yes |
| name | APIM service name | `string` | n/a | yes |
| publisher_email | APIM publisher email address | `string` | n/a | yes |
| resource_group_name | Resource group where APIM is deployed | `string` | n/a | yes |
| publisher_name | APIM publisher name | `string` | `"Apim Example Publisher"` | no |
| sku_name | APIM SKU | `string` | `"Developer_1"` | no |
| virtual_network_type | APIM VNet mode (`None`, `External`, `Internal`) | `string` | `"None"` | no |
| virtual_network_subnet_id | Subnet resource ID when using VNet mode | `string` | `null` | no |
| public_network_access_enabled | Enable/disable management plane public access | `bool` | `true` | no |
| zones | Availability Zones (Premium only) | `list(string)` | `null` | no |
| additional_location | Additional APIM regions | `list(object)` | `[]` | no |
| api_version_sets | API version set definitions | `map(object)` | `{}` | no |
| apis | API definitions including operations/policies | `map(object)` | `{}` | no |
| products | Product definitions and API/group association | `map(object)` | `{}` | no |
| named_values | Named values, including Key Vault references | `map(object)` | `{}` | no |
| subscriptions | APIM subscription definitions | `map(object)` | `{}` | no |
| service_policy | Service-level APIM policy | `object` | `null` | no |
| diagnostic_settings | Diagnostic settings for APIM | `map(object)` | `{}` | no |
| private_endpoints | Private endpoint configuration map | `map(object)` | `{}` | no |
| role_assignments | RBAC assignments for APIM | `map(object)` | `{}` | no |
| managed_identities | Managed identity configuration | `object` | system-assigned false, no user-assigned IDs | no |
| tags | Resource tags | `map(string)` | `null` | no |
| env | Environment code | `string` | n/a | yes |
| au | Accounting Unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| business_owner | Contact name of the application owner | `string` | n/a | yes |
| business_unit | Department owning the resource | `string` | n/a | yes |
| budget_id | Budget or GL code used by Finance | `string` | n/a | yes |
| criticality | Workload criticality | `string` | n/a | yes |
| environment | Environment tag value | `string` | n/a | yes |
| org | Company or business unit code | `string` | `"mbb"` | no |
| region_code | Region code | `string` | `"sea"` | no |
| additional_tags | Additional tags to merge with base tags | `map(string)` | `null` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_api_management.this | resource |
| azurerm_api_management_api_version_set.this | resource |
| azurerm_api_management_api.this | resource |
| azurerm_api_management_api_operation.this | resource |
| azurerm_api_management_api_policy.this | resource |
| azurerm_api_management_api_operation_policy.this | resource |
| azurerm_api_management_policy.this | resource |
| azurerm_api_management_named_value.this | resource |
| azurerm_api_management_product.this | resource |
| azurerm_api_management_product_api.this | resource |
| azurerm_api_management_product_group.this | resource |
| azurerm_api_management_subscription.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint.this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| azurerm_management_lock.this | resource |
| azurerm_role_assignment.this | resource |
| random_uuid.telemetry | resource |
| modtm_telemetry.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| resource_id | ID of the API Management service |
| name | Name of the API Management service |
| apim_gateway_url | APIM gateway URL |
| apim_management_url | APIM management API URL |
| portal_url | APIM portal URL |
| developer_portal_url | APIM developer portal URL |
| scm_url | APIM SCM endpoint URL |
| api_ids | Map of API names to IDs |
| api_operation_ids | Map of API operation keys to operation IDs |
| api_version_set_ids | Map of API version set names to IDs |
| product_ids | Map of product keys to IDs |
| named_value_ids | Map of named value keys to IDs |
| subscription_ids | Map of subscription keys to IDs |
| subscription_keys | Primary and secondary keys by subscription |
| private_endpoints | Map of private endpoints created |

