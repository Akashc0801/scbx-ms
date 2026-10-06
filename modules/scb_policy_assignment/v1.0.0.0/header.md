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
- This module perform the required **Role Assignment(s)** for the `System Assigned Managed Identity` on the scoped resource of the assignment, hence, it is imperative to set `assign_identity` as `true` to perform role assignments.
- This approach ensures the exact **least privileges** assigned and maintained for the Policy Assignment to operate.
- The role assignment being assigned to the Policy Assignment System Identity and being embedded with the assignment itself (thanks to the Terraform module), the ease and security management of the Policy Assignments is optimal.

## Example

```yaml
#--------------------------------------------------------------
#   Policy Assignments
#--------------------------------------------------------------
module "scb_policy_assignment" {
  

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
