[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

<!-- BEGIN_TF_DOCS -->
# Policy Set Definition module

## Overview

- This terraform module creates an Azure Policy Set Definition and associated resources.
- An Azure Initiative, or Policy Set Definition, is a collection of Azure policy definitions that are grouped together towards a specific goal or purpose in mind. Azure initiatives simplify management of policies by grouping a set of policies together as one single item.
- For more information, please refer [What-is-Azure-Initiative definition](https://docs.microsoft.com/en-us/azure/governance/policy/overview#initiative-definition)

## Notes

- Policy Set Definitions (= policy initiatives) do not take effect until they are assigned to a scope using a Policy Assignment.
- This module is designed to parse the [Azure Policy initiative definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure). Another structure will result in creation errors.
- The resulting created Azure Policy Set Definitions can be found in the [Azure Policy | Definitions](https://ms.portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyMenuBlade/Definitions) blade, `definition type` will be **Initiative**.
- The RBAC Roles required to interact with Azure Policy Set Definitions are:

  - The `Resource Policy Contributor` role is required and it includes most Azure Policy operations,
  - The `Owner` role has full rights to perform all activities on the policy definitions and assignments,
  - Both the `Contributor` and `Reader` roles have access to all read Azure Policy operations only. It is important to note that `Contributor` may trigger resource remediation, but can't create definitions or assignments.
  - The RBAC role of `User Access Administrator` is necessary to grant the managed identity on deployIfNotExists or modify assignments necessary permissions,
  - All policy objects will be readable to all roles over the scope.

- All **created** Azure Policies set definitions (= initiatives) must be declared of type `Custom` (case sensitive), in the JSON node `properties.policyType`. The module enforces this,

- To create a Policy Set Definition with the module, create a value for the variable `policy_set_definition` of the module and define:
  - the `policySetDefinitionJsonFile`:
    - give the name of the Policy Initiative JSON file to use,
    - the module assumes all the `JSON` files are stored in a folder at the root of the module named `/policy_set_definitions/`,
  - Without further values, only the JSON content is used to create the Policy Set Definition. It is possible to override values parsed from the JSON file in the `policy_set_definition` with these variables:

```yaml
    name
    display_name
```

- There's a maximum count for each object type for Azure Policy:
  - For definitions, an entry of _Scope_ means the `management group` or `subscription`,
  - For assignments and exemptions, an entry of _Scope_ means the `management group`, `subscription`, `resource group`, or individual `resource`,
  - More information: [Maximum count of Azure Policy objects](https://docs.microsoft.com/en-us/azure/governance/policy/overview#maximum-count-of-azure-policy-objects).

## Example

```yaml

module "SCB-policy-set-definition1" {
  # Local use
  #source = "../../terraform-azurerm-policy-set-definition"

  display_name                = null
  name                        = "Deploy-MDFC-Config"
  policySetDefinitionJsonFile = "policy_set_definition_es_deploy_mdfc_config.tmpl.json"
  management_group_id         = null
}

```

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
| <a name="input_policySetDefinitionJsonFile"></a> [policySetDefinitionJsonFile](#input\_policySetDefinitionJsonFile) | (Required) Relative path of the Azure Policy Set Definition JSON file, under the root folder `policy_set_defintions/`. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) If set or `not null`, this value will replace the value from the Policy Set Definition JSON for the Policy Set Definition `description`. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) If set or `not null`, this value will replace the value from the Policy Set Definition JSON for the Policy Set Definition `display_name`. | `string` | `null` | no |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | (Optional) The ID of the Management Group where this policy should be defined. If using `azurerm_management_group` block to set this variable, be sure to use `name` or `group_id`, but not `id`. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) If set or `not null`, this value will replace the value from the Policy Set Definition JSON for the Policy Set Definition `name`. | `string` | `null` | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_policy_set_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition) | resource |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Policy Set Definition. |

<!-- END_TF_DOCS -->