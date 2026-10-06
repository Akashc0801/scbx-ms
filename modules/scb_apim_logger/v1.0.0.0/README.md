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

- Initial version to deploy Azure API Management Logger (`scb_apim_logger`).

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This Terraform module provisions an Azure API Management Logger and links it to an Azure Application Insights instance using an instrumentation key.
- It applies SCB naming and tagging standards via the shared naming module, ensuring consistent enterprise naming conventions, mandatory governance tags, and optional workload metadata.

## Note

- This module does not create the APIM service or Application Insights resource — both must exist before deploying this module.
- Ensure the instrumentation key belongs to the intended Application Insights instance.

## Network Topology (wherever applicable)

- This module does not create networking resources. It deploys a logger entity into an existing APIM service.

## Azure Service(s) in Scope

- Azure API Management Logger

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Existing Azure API Management service
- Existing Azure Application Insights instance (instrumentation key required)

## Optional Azure services Used (Customer Choice)

- Not applicable

## Limitations

- Only one Application Insights target is supported per logger instance.
- The instrumentation key must be kept secure and not stored in plain text in source control.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This module creates one APIM logger resource linked to Application Insights on an existing APIM service.

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
| scb_apim_logger | [IAC link](https://github.com/Akashc0801/scbx-ms/tree/main/modules/scb_apim_logger) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "apim_logger" {
  source = "../../modules/scb_apim_logger/v1.0.0.0"

  # Required parameters
  logger_name                      = var.logger_name
  apim_name                        = var.apim_name
  resource_group_name              = var.resource_group_name
  app_insights_instrumentation_key = var.app_insights_instrumentation_key

  # Naming module required variables
  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  business_owner     = var.business_owner
  resource_type_code = "logger"

  # Mandatory tags
  environment         = var.environment
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  app_name            = var.app_name
  budget_id           = var.budget_id
  status              = var.status
}
```

```tfvars
logger_name                      = "logger1"
apim_name                        = "apim-myw-test-01"
resource_group_name              = "rg-apim-myw-001"
app_insights_instrumentation_key = "<application-insights-instrumentation-key>"

env                = "tst"
org                = "scb"
region_code        = "myw"
au                 = "00121"
app_code           = "test"
bu                 = "it"
owner              = "CEAT"
resource_type_code = "logger"

environment         = "Test"
business_owner      = "Head of Cloud Engineering and Automation"
business_unit       = "GTD-ISD"
criticality         = "T3"
cost_center         = "383-80572"
data_classification = "Business Sensitive"
compliance          = "BNM RMIT"
app_name            = "Test APIM Logger"
budget_id           = "83254"
status              = "Live"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| logger_name | Name of the APIM logger | `string` | n/a | yes |
| apim_name | Name of the existing APIM service | `string` | n/a | yes |
| resource_group_name | Resource group where APIM exists | `string` | n/a | yes |
| app_insights_instrumentation_key | Application Insights instrumentation key | `string` | n/a | yes |
| env | Environment code | `string` | n/a | yes |
| au | Accounting Unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Azure resource type abbreviation | `string` | `"ampls"` | no |
| business_owner | Contact name of the application owner | `string` | n/a | yes |
| business_unit | Department owning the resource | `string` | `"DefaultBusinessUnit"` | no |
| budget_id | Budget or GL code used by Finance | `string` | n/a | yes |
| environment | Environment tag value | `string` | `"DefaultEnvironment"` | no |
| criticality | Workload criticality | `string` | `"DefaultCriticality"` | no |
| cost_center | Cost center | `string` | `""` | no |
| data_classification | Data classification level | `string` | `"DefaultClassification"` | no |
| compliance | Compliance standard | `string` | `"DefaultCompliance"` | no |
| status | Resource status (`Live`, `Non-Operational`, `Decommissioned`) | `string` | `"DefaultStatus"` | no |
| app_name | Application name | `string` | `"DefaultAppName"` | no |
| org | Company or business unit code | `string` | `"scb"` | no |
| region_code | Region code | `string` | `null` | no |
| base_name | Application/infrastructure base name | `string` | `null` | no |
| additional_name | Additional suffix to create resource uniqueness | `string` | `null` | no |
| iterator | Iterator to create resource uniqueness | `string` | `null` | no |
| max_length | Maximum length of generated name | `number` | `63` | no |
| no_dashes | Remove dashes in generated name | `bool` | `false` | no |
| add_random | Add random characters to name | `bool` | `false` | no |
| rnd_length | Length of random string | `number` | `2` | no |
| additional_tags | Additional tags to merge with module tags | `map(string)` | `null` | no |
| notification_emails | List of email addresses for notifications | `list(string)` | `[]` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_api_management_logger.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| logger_id | Resource ID of the APIM logger |
| logger_name | Name of the APIM logger |
| api_management_name | APIM instance name used by the logger |





## Overview

This is the SCB standardized implementation of Azure API Management (APIM) Logger integration.
The module provisions an APIM logger and links it to Azure Application Insights using an instrumentation key.

The module also applies SCB naming and tagging standards via the shared naming module:
- Consistent enterprise naming convention
- Mandatory governance, finance, and operations tags
- Optional workload metadata for extended reporting

## What's in v1.0.0.0

Initial SCB baseline release for APIM logger provisioning with:
1. APIM logger resource deployment
2. Application Insights linkage
3. SCB naming and tagging framework integration

---

## Security and Governance Baseline

This module is aligned to SCB operational governance by default:
- Logger identity and metadata are standardized through naming controls
- Tagging supports cost, ownership, compliance, and lifecycle accountability
- Logger telemetry is centralized through Application Insights integration

---

## Pre-Deployment Requirements

Before deployment, ensure all prerequisites are available:

1. Existing Azure API Management instance
2. Existing Azure Application Insights resource
3. Target resource group exists
4. Terraform runner identity has at minimum:
   - Microsoft.ApiManagement/service/loggers/*
   - Microsoft.Insights/components/read
   - Microsoft.Resources/subscriptions/resourceGroups/read

---

## Module Usage

### Example: main.tf

```hcl
module "apim_logger" {
  source = "../../scb-az-iac-modules/modules/scb_apim_logger/v1.0.0.0"

  logger_name                      = "logger1"
  apim_name                        = "apim-myw-test-01"
  resource_group_name              = "scb-rg-apim-tst-myw-apimexternal-test-01"
  app_insights_instrumentation_key = "<application-insights-instrumentation-key>"

  # Naming variables
  env                = "tst"
  org                = "scb"
  region_code        = "myw"
  base_name          = "apimlogger"
  additional_name    = "test"
  iterator           = "01"
  au                 = "00121"
  app_code           = "test"
  bu                 = "it"
  owner              = "CEAT"
  resource_type_code = "logger"
  max_length         = 80
  no_dashes          = true
  add_random         = false
  rnd_length         = 4

  # Mandatory tags
  environment         = "Test"
  business_owner      = "Head of Cloud Engineering and Automation"
  business_unit       = "GTD-ISD"
  criticality         = "T3"
  cost_center         = "383-80572"
  data_classification = "Business Sensitive"
  compliance          = "BNM RMIT"
  app_name            = "Test APIM Logger"
  budget_id           = "83254"
  status              = "Live"

  # Optional tags
  service = "API Management"
  region  = "MYW"

  additional_tags = {
    support_model = "platform"
  }
}
```

### Example: terraform.tfvars

```hcl
logger_name                      = "logger1"
apim_name                        = "apim-myw-test-01"
resource_group_name              = "scb-rg-apim-tst-myw-apimexternal-test-01"
app_insights_instrumentation_key = "<application-insights-instrumentation-key>"

env                = "tst"
org                = "scb"
region_code        = "myw"
base_name          = "apimlogger"
additional_name    = "test"
iterator           = "01"
au                 = "00121"
app_code           = "test"
bu                 = "it"
owner              = "CEAT"
resource_type_code = "logger"

environment         = "Test"
business_owner      = "Head of Cloud Engineering and Automation"
business_unit       = "GTD-ISD"
criticality         = "T3"
cost_center         = "383-80572"
data_classification = "Business Sensitive"
compliance          = "BNM RMIT"
app_name            = "Test APIM Logger"
budget_id           = "83254"
status              = "Live"
```

---

## Input Summary

### Required Inputs

- logger_name
- apim_name
- resource_group_name
- app_insights_instrumentation_key
- env
- au
- app_code
- bu
- owner
- business_owner
- budget_id
- service

### Optional Inputs

- org
- region_code
- base_name
- additional_name
- iterator
- naming controls (max_length, no_dashes, add_random, rnd_length)
- extended tags (tier, app_id, auto_delete, auto_shutdown, backup_policy, disaster_recovery, integration_id, retention, sandbox_type, maintenance_window, patch_policy, etc.)
- additional_tags

---

## Outputs

The module exports:
- logger_id: Resource ID of the APIM logger
- logger_name: Name of the APIM logger
- api_management_name: APIM instance name used by the logger

---

## Notes

- This module does not create APIM or Application Insights resources.
- Ensure the instrumentation key belongs to the intended Application Insights instance.
- Keep naming and tag values aligned with SCB enterprise standards.

<!-- END_TF_DOCS -->
