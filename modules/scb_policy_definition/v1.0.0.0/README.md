[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

<!-- BEGIN_TF_DOCS -->
# Azure Policy Definition module

## Overview

The scb Policy Definition module creates one Azure Policy definition by parsing the `*.json` file referenced in the folder `/policy_definitions/` (or sub-folder). The `JSON` file contains the Azure Policy Definition.

Azure Policy helps to enforce organizational standards and to assess compliance at-scale. Through its [compliance dashboard](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Compliance), it provides an aggregated view to evaluate the overall state of the environment, with the ability to drill down to the per-resource, per-policy granularity. It also helps to bring resources to compliance through bulk remediation for existing resources and automatic remediation for new resources.

To read more on Azure Policy, please refer to [What is Azure Policy?](https://docs.microsoft.com/en-us/azure/governance/policy/overview).

## Notes

- This module is designed to parse the [JSON Azure policy definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#avoiding-template-failures). Another structure will result in creation errors,
- The resulting created Azure Policy Definitions can be found in the [Azure Policy | Definitions](https://ms.portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) blade,
- The RBAC Roles required to interact with Azure Policy Definitions are:

  - The `Resource Policy Contributor` role is required and it includes most Azure Policy operations,
  - The `Owner` role has full rights to perform all activities on the policy definitions and assignments,
  - Both the `Contributor` and `Reader` roles have access to all read Azure Policy operations only. It is important to note that `Contributor` may trigger resource remediation, but can't create definitions or assignments,
  - The RBAC role of `User Access Administrator` is necessary to grant the managed identity on deployIfNotExists or modify assignments necessary permissions,
  - All policy objects will be readable to all roles over the scope.

- All **created** Azure Policies definitions must be declared of type `Custom` (case sensitive), in the JSON node `properties.policyType`. The module enforces this,

- To create a Policy Definition with the module, set:
  - the `policyDefinitionJsonFile`:
    - give the name of the Policy Assignment JSON file to use,
    - the module assumes all the `JSON` files are stored in a folder at the root of the module named `/policy_definitions/`,
    - the folder can contain sub folders. In that case the filename value should match this structure: `sub/policy_definition1.json`,
  - To create the Policy Definition at a Management group level, the variable `management_group_id` must be set. If using `azurerm_management_group` block to set this variable, be sure to use `name` or `group_id`, but not `id`.
  - Without further inputs, the JSON content is used to create the Policy Definition,
  - It is possible to override the JSON values by declaring values for these variables:

```yaml
        name
        display_name
        description
        mode
```

- There's a maximum count for each object type for Azure Policy:
  - For definitions, an entry of _Scope_ means the `management group` or `subscription`,
  - For assignments and exemptions, an entry of _Scope_ means the `management group`, `subscription`, `resource group`, or individual `resource`,
  - More information: [Maximum count of Azure Policy objects](https://docs.microsoft.com/en-us/azure/governance/policy/overview#maximum-count-of-azure-policy-objects).

## Example

```yaml
#-------------------------------------------
#    Policy Definition module
#------------------------------------------
module "wf-policy-definition" {

  source = "../../terraform-azurerm-policydefinition"

  # Required variable
  policyDefinitionJsonFile = "Resource_Group_Tags.json"

  # Optional variables
  name                = "Resource_Group_Tags_mgmt"
  display_name        = "Resource_Group_Tags_mgmt"
  # description         = null
  # mode                = null
  management_group_id = "ashish"
}
```

Note: For the example to work locally, a replacement is required in the line 17 of `main.tf`: `${path.root}` must be replaced by `${path.module}`.

## Documentation
<!-- markdownlint-disable MD033 -->

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.89.0 |

### Modules

No modules.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policyDefinitionJsonFile"></a> [policyDefinitionJsonFile](#input\_policyDefinitionJsonFile) | (Required) Relative path of the Azure Policy Definition JSON file, under the root folder `policy_defintions/`. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `description`. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `display_name`. | `string` | `null` | no |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | (Optional) The ID of the Management Group where this policy should be defined. If using `azurerm_management_group` block to set this variable, be sure to use `name` or `group_id`, but not `id`. | `string` | `null` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | (Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `mode`. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `name`. | `string` | `null` | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID for the Policy Definition. |

<!-- END_TF_DOCS -->