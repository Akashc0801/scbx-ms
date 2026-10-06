[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable MD033 -->
# Azure Policy Assignment module

## Overview

This terraform module creates one Azure Policy Assignment to a defined scope.

When business rules are selected (Built-in) or created (Custom), they need to be assigned to the scope they apply to, with the associated parameters.

An Azure Policy Assignment will link these 4 main elements:

1. The **Azure Policy Definition** (see [Azure Policy definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure)) of the assignment:
    - it captures the evaluation rules, like the presence of a tag, or a tag's value,
    - it defines the "[effect](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)" of the policy when the evaluation is matched,
    - some of these effects will require to **alter the resource(s)**. In that case, the Policy Definition includes `roleDefinitionIds`: this is an array of strings that match RBAC role ID(s) accessible by the subscription. For more information, see [remediation - configure policy definition](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources#configure-policy-definition),

2. The **Azure Scope** of the assignment:
    - Scope in Azure Policy is based on how scope works in Azure Resource Manager. For a high-level overview, see [Scope in Azure Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#understand-scope),
    - The main Azure scopes and their structure are captured in this figure:

        <img src="https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/media/overview/scope-levels.png" alt="Azure scopes" width="300"/>

    - To do an Azure Policy Assignment, its scope must be defined,
    - The same Azure Policy Definition can be assigned to different scopes,

3. The **Enforcement Mode** of the assignment:
    - The `enforcementMode` property provides the ability to **test** the outcome of a policy on existing resources **without initiating the policy effect** or triggering entries in the Azure Activity log.
    - This option is commonly referred to as **"What If"** and aligns to safe deployment practices.
    - `enforcementMode` is **different** from the `Disabled` effect, as that effect prevents resource evaluation from happening at all,
    - Possible values are:

Mode | JSON Value | Activity log entry | Description |
---------|----------|---------|---------|
 `Enabled` | Default | Yes | The policy effect **is enforced** during resource creation or update. |
 `Disabled` | DoNotEnforce | No | The policy effect **isn't enforced** during resource creation or update. |

4. The eventual **Parameters** of the assignment:
    - Policy parameters help simplify policies management by reducing the number of policy definitions to create,
    - Parameters can be defined when creating a policy definition to make the policy more generic,
    - Then the Policy Definition can be reused for different scenarios, by passing in different parameters' values when assigning the policy definition.
    - Parameters are defined when creating a policy definition,
    - When a parameter is defined, it's given a name and optionally given a value,
    <!-- - For example, a parameter could be defined for a policy titled location. Then different values such as NorthCentralUS or SouthCentralUS can be set when assigning the policy (with this module), -->
    - For more information about policy parameters, see [Definition structure - Parameters](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameters).

## Notes

- Azure Policy is `JSON` based:
  - [Azure Policy Definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure),
  - [Azure Policy Assignment structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure),
- When the Policy Definition assigned includes `roleDefinitionIds`, the module creates a `System Managed Identity` for the Policy Assignment,
- This module performs the required **Role Assignment(s)** for the `System Assigned Managed Identity` on the scoped resource of the assignment, hence, it is imperative to set `assign_identity` as `true` to perform role assignments.
- This approach ensures the exact **least privileges** assigned and maintained for the Policy Assignment to operate.
- The role assignment being assigned to the Policy Assignment System Identity and being embedded with the assignment itself (thanks to the Terraform module), the ease and security management of the Policy Assignments is optimal.

## Example

```yaml
#--------------------------------------------------------------
#   Policy Assignments
#--------------------------------------------------------------
module "scb_policy_assignment" {

    source = "../"

    
  name                               = "Deploy-MDFC-Config-21"
  description                        = "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements."
  display_name                       = "Deploy MDFC Config 2"
  not_scopes                         = []
  metadata                           = null
  parameters                         = null
  policy_definition_id               = "/providers/Microsoft.Management/managementGroups/test/providers/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config_2"
  scope                              = "/providers/Microsoft.Management/managementGroups/test"                                                                       
  enforcement_mode                   = null
  location                           = null
  assign_identity                    = true
  management_group_set_definition    = "test"
  management_group_policy_definition = null
}
```

## Manual Role Assignment for Policy Sets

For policy sets where automatic role extraction is not supported due to Terraform limitations, you can now manually specify the required role definitions:

### Example: Policy Set with Manual Roles

```hcl
module "policy_set_with_manual_roles" {
  source = "../"
  
  name                 = "enforce-enhanced-security"
  policy_definition_id = "/providers/Microsoft.Management/managementGroups/your-mg/providers/Microsoft.Authorization/policySetDefinitions/enforce-enhanced-security-controls"
  scope                = "/providers/Microsoft.Management/managementGroups/your-mg"
  assign_identity      = true
  
  # Manually specify role definitions required by policies within the policy set
  manual_role_definition_ids = [
    "/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab", # Storage Contributor
    "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c", # Contributor
    "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa"  # Monitoring Contributor
  ]

  parameters = {
    listOfResourceTypesNotAllowed = {
      value = [
        "Microsoft.Network/networkSecurityGroups",
        "Microsoft.Storage/storageAccounts"
      ]
    }
  }
}
```

### Example: Individual Policy (Auto Role Assignment)

```hcl
module "individual_policy" {
  source = "../"
  
  name                 = "require-storage-encryption"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  scope                = "/subscriptions/your-subscription-id"
  assign_identity      = true
  
  # No manual role definitions needed - automatically extracted from policy!
}
```

### Role Assignment Behavior

| Scenario | Individual Policies | Policy Sets |
|----------|-------------------|-------------|
| **Automatic Role Extraction** | ✅ Supported | ❌ Not supported (Terraform limitations) |
| **Manual Role Specification** | ✅ Supported (combined with auto) | ✅ Supported |
| **Identity Creation** | ✅ When `assign_identity = true` | ✅ When `assign_identity = true` |
| **Role Assignment Creation** | ✅ Automatic when roles found | ✅ When `manual_role_definition_ids` provided |

## Documentation
<!-- markdownlint-disable MD033 -->

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_scb_role_assignments"></a> [scb\_role\_assignments](#module\_scb\_role\_assignments) | app.terraform.io/msftscbdeo/scb-role-assignment/azurerm | ~>1.0.1 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name which should be used for this Policy Assignment. | `string` | n/a | yes |
| <a name="input_policy_definition_id"></a> [policy\_definition\_id](#input\_policy\_definition\_id) | (Required) The ID of the Policy Definition or Policy Definition Set. | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) The scope where this Policy Assignment should be created. | `string` | n/a | yes |
| <a name="input_assign_identity"></a> [assign\_identity](#input\_assign\_identity) | (Optional) Whether or not to assign System Assigned Identity to the Policy Assignment. It is required to enable this for enabling role assignments on Managed Identity. | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description which should be used for this Policy Assignment. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) The Display Name for this Policy Assignment. | `string` | `null` | no |
| <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode) | (Optional) Specifies if this Policy should be enforced or not? | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The Azure Region where the Policy Assignment should exist. | `string` | `null` | no |
| <a name="input_management_group_policy_definition"></a> [management\_group\_policy\_definition](#input\_management\_group\_policy\_definition) | (Optional) Name of management group from which policy definition will be fetched. | `string` | `null` | no |
| <a name="input_management_group_set_definition"></a> [management\_group\_set\_definition](#input\_management\_group\_set\_definition) | (Optional) Name of management group from which policy set definition will be fetched. | `string` | `null` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | (Optional) A JSON mapping of any Metadata for this Policy. | `any` | `null` | no |
| <a name="input_not_scopes"></a> [not\_scopes](#input\_not\_scopes) | (Optional) Specifies a list of Resource Scopes (for example a Subscription, or a Resource Group) within this Management Group which are excluded from this Policy. | `list(string)` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) A JSON mapping of any Parameters for this Policy. | `any` | `null` | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_management_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) | resource |
| [azurerm_subscription_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_policy_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_set_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_set_definition) | data source |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Azure Policy Assignment. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | The ID(s) of the Role Assignment(s). |

<!-- END_TF_DOCS -->