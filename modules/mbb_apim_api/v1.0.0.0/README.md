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

- Initial version to deploy Azure API Management API entities (`mbb_apim_api`).

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This Terraform module creates and configures Azure API Management API entities on an existing APIM instance.
- It manages APIs, API version sets, API operations, API-level policies, and operation-level policies.
- Protocols are enforced to HTTPS only by the module security baseline, regardless of input.
- Policy content can be supplied as raw XML, a URL link, or rendered from a template file with substitution variables.

## Note

- An existing APIM service must be provisioned separately before using this module.
- API path values must not contain the characters: `*`, `#`, `&`, `+`, `:`, `<`, `>`, `?`.

## Network Topology (wherever applicable)

- This module does not create networking resources. It deploys API entities into an existing APIM instance.

## Azure Service(s) in Scope

- Azure API Management (API entities)

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Existing Azure API Management service

## Optional Azure services Used (Customer Choice)

- Azure Key Vault (for policy secrets referenced via named values in the parent APIM instance)

## Limitations

- HTTPS is the only allowed protocol — `protocols` input values are ignored and enforced by the module.
- Operation HTTP method must be one of: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`, `OPTIONS`, `TRACE`.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This module configures API entities (APIs, version sets, operations, and policies) on an existing APIM service.

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
| mbb_apim_api | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_apim_api) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "apim_api" {
  source = "../../modules/mbb_apim_api/v1.0.0.0"

  # Required parameters
  apim_name           = var.apim_name
  resource_group_name = var.resource_group_name

  # API version sets (optional)
  api_version_sets = var.api_version_sets

  # API definitions
  apis = var.apis

  # Common policy variables available to all policy templates
  common_policy_vars = var.common_policy_vars

  # Naming module required variables
  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  business_owner     = var.business_owner
  resource_type_code = "apim"
}
```

```tfvars
apim_name           = "apim-mybk-sea-001"
resource_group_name = "rg-apim-sea-001"

api_version_sets = {}

apis = {
  "orders" = {
    display_name          = "Orders API"
    path                  = "orders"
    service_url           = "https://backend-orders.internal.local"
    subscription_required = true

    policy = {
      xml_content = <<XML
<policies>
  <inbound>
    <base />
  </inbound>
</policies>
XML
    }

    operations = {
      "get-orders" = {
        display_name = "Get Orders"
        method       = "GET"
        url_template = "/"
      }
    }
  }
}

common_policy_vars = {}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apim_name | Name of the existing APIM service | `string` | n/a | yes |
| resource_group_name | Resource group of the existing APIM service | `string` | n/a | yes |
| apis | Map of API definitions including operations and policies | `map(object)` | `{}` | no |
| api_version_sets | Map of API version set definitions | `map(object)` | `{}` | no |
| common_policy_vars | Common variables available to all policy templates | `map(any)` | `{}` | no |
| env | Environment code | `string` | n/a | yes |
| au | Accounting Unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Azure resource type abbreviation | `string` | n/a | yes |
| business_owner | Contact name of the application owner | `string` | n/a | yes |
| business_unit | Department owning the resource | `string` | n/a | yes |
| criticality | Workload criticality | `string` | n/a | yes |
| environment | Environment tag value | `string` | n/a | yes |
| cost_center | Cost center | `string` | n/a | yes |
| data_classification | Data classification level | `string` | n/a | yes |
| compliance | Compliance standard | `string` | n/a | yes |
| budget_id | Budget or GL code used by Finance | `string` | `""` | no |
| org | Company or business unit code | `string` | `"mbb"` | no |
| region_code | Region code | `string` | `"sg"` | no |
| additional_tags | Additional tags to merge with base tags | `map(string)` | `null` | no |
| openid_config_url | OpenID Connect configuration URL for JWT validation policies | `string` | `""` | no |
| audience | JWT audience for validate-jwt policy | `string` | `""` | no |
| issuer | JWT issuer for validate-jwt policy | `string` | `""` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_api_management_api_version_set.this | resource |
| azurerm_api_management_api.this | resource |
| azurerm_api_management_api_operation.this | resource |
| azurerm_api_management_api_policy.this | resource |
| azurerm_api_management_api_operation_policy.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| api_ids | Map of API keys to their resource IDs |
| api_names | List of created API names |
| api_version_set_ids | Map of version set keys to their resource IDs |
| operation_ids | Map of operation keys to their operation IDs |


## Overview
This module manages Azure API Management API entities, including:

- APIs
- API operations
- Configuring API-level policies
- configuring Operation-level policies

It is intended to be used with an existing APIM instance (internal or external).

---

## Prerequisites

- Terraform `>= 1.5`
- AzureRM provider `>= 4.0`
- Existing APIM service
- Deployment identity with:
  - `Microsoft.ApiManagement/service/apis/*`
  - `Microsoft.ApiManagement/service/apis/operations/*`
  - `Microsoft.ApiManagement/service/apis/policies/*`

---

## Supported Capabilities

- Create one or many APIs with a map input.
- Create operations per API.
- Apply API policy using template + variables.
- Apply operation policy using template + variables.
- Version-set mapping (if supported by input object).

---

## Example Usage

```hcl
module "orders_api_test" {
  source = "../../../mbb-az-iac-modules/modules/mbb_apim_api/v1.0.0.0"

  resource_group_name = "rg-apim-test-sea-01"
  api_management_name = "apim-test-sea-01"

  apis = {
    orders = {
      display_name          = "Orders API"
      revision              = "1"
      path                  = "orders"
      protocols             = ["https"]
      service_url           = "https://backend-orders.internal.local"
      subscription_required = true

      # API-level policy
      policy = {
        policy_template = "${path.module}/../../../mbb-az-iac-modules/modules/mbb_apim_policies/v1.0.0.0/01-correlation.xml"
        policy_vars = {
          correlation_variable_name = "corrId"
          correlation_header_name   = "x-correlation-id"
          header_exists_action      = "override"
        }
      }

      operations = {
        get_orders = {
          display_name = "Get Orders"
          method       = "GET"
          url_template = "/"

          # Operation-level policy
          policy = {
            policy_template = "${path.module}/../../../mbb-az-iac-modules/modules/mbb_apim_policies/v1.0.0.0/05-rate-limit-by-key.xml"
            policy_vars = {
              rate_limit_calls               = "100"
              rate_limit_period              = "60"
              rate_limit_counter_key         = "@(context.Subscription.Id)"
              rate_limit_increment_condition = "@(true)"
            }
          }
        }
      }
    }
  }
}
```

---

## Input Contract (Typical)

```hcl
resource_group_name = string
api_management_name = string

apis = map(object({
  display_name          = string
  revision              = optional(string, "1")
  path                  = string
  protocols             = optional(list(string), ["https"])
  service_url           = optional(string)
  subscription_required = optional(bool, true)

  policy = optional(object({
    policy_template = string
    policy_vars     = map(string)
  }))

  operations = optional(map(object({
    display_name = string
    method       = string
    url_template = string

    policy = optional(object({
      policy_template = string
      policy_vars     = map(string)
    }))
  })), {})
}))
```

---

## Outputs (Typical)

- `api_ids` — map of API keys to IDs
- `api_operation_ids` — map of operation keys to IDs
- `apis` — API resource details
- `api_operations` — operation resource details

---

## Policy Notes

- API policy and operation policy are independent and can both be used.
- If a policy template uses variables, all required variables must be passed in `policy_vars`.
- `increment-condition` using `context.Response` must be evaluated in policy section where response is available.

---

## Troubleshooting

### 1) Missing template variable
Error similar to:
`vars map does not contain key ...`

Fix: add the missing key in `policy_vars`.

### 2) Template file not found
Fix: verify relative path from the Terraform execution directory, or use `${path.module}`-based path.

### 3) API replacement during plan
If immutable API properties changed (`path`, versioning linkage, etc.), Terraform may show `-/+` (replace).

---

## Recommended Workflow

```powershell
terraform fmt -recursive
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## Version

- Module: `mbb_apim_api`
- Current documented version: `v1.0.0.0`

