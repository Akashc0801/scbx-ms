[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.1 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

# About this product version

## Product State: Released

## Product Category

- Messaging

## Notable changes in this version

### v1.0.0.1

- Integrated scb naming module for consistent resource naming and tagging.
- Removed AVM references and replaced with SCB conventions.

### v1.0.0.0

- Initial version to deploy Azure Event Hub Namespace and Event Hubs in Azure.

## Upgrade Path

- From v1.0.0.0: Update module source to v1.0.0.1. Replace `name` and `location` variables with naming module variables (`env`, `au`, `owner`, `resource_type_code`, `app_code`, `bu`, `region_code`).

# Product Description

## Overview

- Azure Event Hubs is a big data streaming platform and event ingestion service. It can receive and process millions of events per second. Data sent to an event hub can be transformed and stored by using any real-time analytics provider or batching/storage adapters.

It comes in 3 SKUs:

- Basic,
- Standard,
- Premium.

Their features are compared in this [table](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-quotas).

Key capabilities include:

- **Event ingestion**: Event Hubs can ingest millions of events per second with low latency.
- **Capture**: Automatically capture streaming data into Azure Blob Storage or Azure Data Lake Storage.
- **Partitioning**: Distribute events across multiple partitions for parallel processing.
- **Consumer groups**: Provide independent views of the event stream.
- **Private endpoints**: Secure access over a private network.
- **Customer-managed keys**: Encrypt data at rest with your own keys.

## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Event Hub Namespace
- Event Hub

## Azure Services Needed (Pre-Requisites)

- Resource Group

## Optional Azure services Used (Customer Choice)

- Private Endpoint
- Key Vault (for Customer Managed Keys)
- Log Analytics Workspace (for Diagnostic Settings)
- Storage Account (for Diagnostic Settings / Event Capture)
- User Assigned Managed Identity

## Limitations

- None

# Product Security

- Supports Customer Managed Keys for encryption at rest
- Supports Private Endpoints for secure network access
- Supports disabling local/SAS authentication in favor of EntraID
- Supports disabling public network access
- Supports Managed Identities (System and User Assigned)

# Product Usage Guidance

## Overview

- This terraform module creates an `Azure Event Hub Namespace` and optionally one or more `Event Hubs` within it.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |

### GitHub Packages

| Name | Source | Version |
|------|--------|---------|
| SCB-ccoe-azure-products | [scb_eventhub](https://github.com/orgs/SCBCloud/packages) | 1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to fetch this product from GitHub Packages

- step created in the pipeline (yaml)

```yaml
      - name: Download scb_eventhub
        uses: actions/checkout@v4
        with:
          repository: SCBCloud/scb-az-iac-modules
          token: ${{ secrets.GH_PACKAGES_TOKEN }}
          path: Level-2/terraform-baseinfra
```

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "eventhub_prod" {

  source = "../../Level-2/terraform-baseinfra/modules/scb_eventhub/v1.0.0.1"

    providers = {
      azurerm = azurerm.hub
    }

    # Naming module parameters
    env                = var.env
    base_name          = var.base_name
    au                 = var.au
    owner              = var.owner
    org                = var.org
    region_code        = var.region_code
    bu                 = var.bu
    app_code           = var.app_code
    resource_type_code = "evhns"
    iterator           = "001"

    # Mandatory tags
    environment         = var.environment
    business_owner      = var.business_owner
    business_unit       = var.business_unit
    criticality         = var.criticality
    cost_center         = var.cost_center
    data_classification = var.data_classification
    compliance          = var.compliance
    app_name            = var.app_name
    budget_id           = var.budget_id

    # Resource configuration
    resource_group_name = module.resource_group.name
    sku                 = "Standard"
    capacity            = 1

    event_hubs = {
      eh1 = {
        name              = "my-event-hub"
        partition_count   = 2
        message_retention = 1
      }
    }

    depends_on = [module.resource_group]
}
```

- terraform Variables

```tfvars
    sku      = "Standard"
    capacity = 1
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) scb environment code. Example: `test`. | `string` | n/a | yes |
| <a name="input_au"></a> [au](#input\_au) | (Required) scb Accounting Unit (AU) code. Example: `0233985`. <br></br>&#8226; Value of `au` must be of numeric characters. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | (Required) scb technology owner group. | `string` | n/a | yes |
| <a name="input_resource_type_code"></a> [resource\_type\_code](#input\_resource\_type\_code) | (Required) Azure resource type abbreviation. Example: `evhns`. | `string` | n/a | yes |
| <a name="input_app_code"></a> [app\_code](#input\_app\_code) | (Required) scb application code. Example: `network`, `mgmt`, `build`. | `string` | n/a | yes |
| <a name="input_bu"></a> [bu](#input\_bu) | (Required) scb business unit code. Example: `IT`, `scb`. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group where resources will be deployed. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Environment where the resource is located. | `string` | n/a | yes |
| <a name="input_business_owner"></a> [business\_owner](#input\_business\_owner) | (Required) Contact name of the application owner. | `string` | n/a | yes |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | (Required) Department that owns the resources. | `string` | n/a | yes |
| <a name="input_criticality"></a> [criticality](#input\_criticality) | (Required) Workload SLA requirements. | `string` | n/a | yes |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | (Required) Cost center that should bear the costs. | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | (Required) Data classification level. | `string` | n/a | yes |
| <a name="input_compliance"></a> [compliance](#input\_compliance) | (Required) Specific standard/regulation. | `string` | `"None"` | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Required) Human readable name for the Application. | `string` | n/a | yes |
| <a name="input_budget_id"></a> [budget\_id](#input\_budget\_id) | (Required) Budget or GL code used by Finance. | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | (Optional) scb organization code. Example: `scb`. | `string` | `"scb"` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | (Optional) scb region code. Value must be one of: `[ea,sea,eu,myw,sg,idc]`. | `string` | `"sea"` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | (Optional) Application/Infrastructure base name. Example: `aks`. | `string` | `null` | no |
| <a name="input_additional_name"></a> [additional\_name](#input\_additional\_name) | (Optional) Additional suffix to create resource uniqueness. Example: `lan1`. | `string` | `null` | no |
| <a name="input_iterator"></a> [iterator](#input\_iterator) | (Optional) Iterator to create resource uniqueness. Example: `001`. | `string` | `null` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | (Optional) Additional base tags. | `map(string)` | `null` | no |
| <a name="input_add_random"></a> [add\_random](#input\_add\_random) | (Optional) When set to `true`, it will add a random number at the name's end. | `bool` | `false` | no |
| <a name="input_max_length"></a> [max\_length](#input\_max\_length) | (Optional) Max length of the generated name. | `number` | `256` | no |
| <a name="input_no_dashes"></a> [no\_dashes](#input\_no\_dashes) | (Optional) Remove all dashes from the generated name. | `bool` | `false` | no |
| <a name="input_rnd_length"></a> [rnd\_length](#input\_rnd\_length) | (Optional) Set the length of the random number generated. | `number` | `2` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) Tier for the Event Hub Namespace. Options: Basic, Standard, Premium. | `string` | `"Standard"` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | (Optional) Specifies Capacity/Throughput Units for Standard SKU namespace. | `number` | `1` | no |
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | (Optional) Is Auto Inflate enabled for the Event Hub Namespace? | `bool` | `false` | no |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | (Optional) Max throughput units when Auto Inflate is enabled. Valid: 1-20. | `number` | `null` | no |
| <a name="input_dedicated_cluster_id"></a> [dedicated\_cluster\_id](#input\_dedicated\_cluster\_id) | (Optional) ID of EventHub Dedicated Cluster where Namespace should be created. | `string` | `null` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | (Optional) Is SAS authentication enabled for the EventHub Namespace? | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Is public network access enabled? | `bool` | `false` | no |
| <a name="input_event_hubs"></a> [event\_hubs](#input\_event\_hubs) | (Optional) Map of Event Hubs to create with partition_count, message_retention, status, capture_description, role_assignments. | `map(object)` | `{}` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | (Optional) Customer Managed Key configuration with key_vault_resource_id, key_name, key_version, user_assigned_identity. | `object` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | (Optional) Map of diagnostic settings with log categories, metrics, and destinations. | `map(object)` | `{}` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | (Optional) Map of private endpoints with subnet_resource_id, DNS zones, role_assignments, locks. | `map(object)` | `{}` | no |
| <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group) | (Optional) Whether to manage private DNS zone groups. | `bool` | `true` | no |
| <a name="input_lock"></a> [lock](#input\_lock) | (Optional) Resource Lock. `kind`: CanNotDelete or ReadOnly. | `object` | `null` | no |
| <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities) | (Optional) Managed Identity with system_assigned and user_assigned_resource_ids. | `object` | `{}` | no |
| <a name="input_network_rulesets"></a> [network\_rulesets](#input\_network\_rulesets) | (Optional) Network rule set with default_action, ip_rule, virtual_network_rule. | `object` | `null` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | (Optional) Map of namespace-level role assignments. | `map(object)` | `{}` | no |
| <a name="input_existing_parent_resource"></a> [existing\_parent\_resource](#input\_existing\_parent\_resource) | (Optional) Existing Event Hub namespace to use instead of creating new. | `object` | `null` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | (Optional) Enable telemetry for the module. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Additional tags to assign to the resource. | `map(string)` | `null` | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.event_hubs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_eventhub_namespace_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_customer_managed_key) | resource |
| [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace) | data source |
| [azurerm_resource_group.parent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | A map of the private endpoints created. |
| <a name="output_resource"></a> [resource](#output\_resource) | The full output for the EventHub Namespace resource. |
| <a name="output_resource_eventhubs"></a> [resource\_eventhubs](#output\_resource\_eventhubs) | A map of all Event Hubs created. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The full resource ID of the EventHub Namespace. |
