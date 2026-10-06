[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

# scb_policy_exemption

A reusable Terraform module to create Azure Policy Exemptions for policy assignments or policy set assignments at various scopes (Management Group, Subscription, Resource Group, or Resource level).

## Features
- Supports exemptions at multiple Azure scopes:
  - Management Group level
  - Subscription level
  - Resource Group level
  - Resource level
- Automatic scope detection using regex patterns
- Support for single or multiple policy definition reference IDs within policy sets
- Configurable exemption category and expiration
- Comprehensive outputs for integration

## Usage

### Exempt Multiple Policies in a Policy Set
```hcl
module "multiple_policy_exemption" {
  source                           = "../scb_policy_exemption/v1.0.0.0"
  name                             = "exempt-kubernetes-security"
  scope                            = azurerm_resource_group.example.id
  policy_assignment_id             = azurerm_resource_group_policy_assignment.example.id
  exemption_category               = "Waiver"

  # Exempt multiple policies from the same policy set
  policy_definition_reference_ids = [
    "DeployAKSPolicyAddOn",
    "KubernetesPrivilegedContainers",
    "KubernetesPrivilegeEscalation"
  ]

  expires_on = "2026-12-31T23:59:59Z"
}
```

### Exempt Multiple Resources (Multiple Scopes)
```hcl
module "multi_scope_exemption" {
  source                = "../scb_policy_exemption/v1.0.0.0"
  name                  = "exempt-two-vms"
  scopes                = [
    azurerm_linux_virtual_machine.vm1.id,
    azurerm_linux_virtual_machine.vm2.id
  ]
  policy_assignment_id  = azurerm_resource_group_policy_assignment.example.id
  exemption_category    = "Waiver"
}
```

### Exempt Single Policy in a Policy Set
```hcl
module "single_policy_exemption" {
  source                          = "../scb_policy_exemption/v1.0.0.0"
  name                            = "exempt-aks-addon"
  scope                           = azurerm_resource_group.example.id
  policy_assignment_id            = azurerm_resource_group_policy_assignment.example.id
  exemption_category              = "Mitigated"
  policy_definition_reference_id  = "DeployAKSPolicyAddOn"

  description = "Temporary mitigation in place"
  expires_on  = "2026-06-30T23:59:59Z"
}
```

### Exempt at Subscription scope
```hcl
module "sub_policy_exemption" {
  source              = "../scb_policy_exemption/v1.0.0.0"
  name                = "exempt-subscription-policies"
  scope               = "/subscriptions/12345678-1234-1234-1234-123456789012"
  policy_assignment_id = azurerm_subscription_policy_assignment.example.id
  exemption_category  = "Waiver"
}
```

### Exempt at Resource Group scope (Advanced Configuration)
```hcl
module "rg_policy_exemption" {
  source                         = "../scb_policy_exemption/v1.0.0.0"
  name                           = "exempt-rg-aks-policies"
  scope                          = azurerm_resource_group.example.id
  policy_assignment_id           = azurerm_resource_group_policy_assignment.example.id
  policy_definition_reference_id = "KubernetesPrivilegedContainers"
  exemption_category             = "Waiver"
  display_name                   = "AKS privileged containers exemption"
  description                    = "Approved exception for break-glass workload"
  expires_on                     = "2026-12-31T23:59:59Z"
  metadata = {
    approvedBy = "security-team"
    ticketId   = "INC123456"
  }
}
```

## Variables
- `name` (string, required): Base name for the exemption(s)
- `scope` (string, optional): Single scope for the exemption (auto-detects scope type)
- `scopes` (list(string), optional): Multiple scopes for exemptions (use for multiple resources)
- `policy_assignment_id` (string, required): Policy assignment ID to exempt
- `exemption_category` (string, required): Exemption category (`Waiver` or `Mitigated`)
- `display_name` (string, optional): Display name for the exemption
- `description` (string, optional): Description for the exemption
- `expires_on` (string, optional): Expiration date in RFC3339 format
- `metadata` (any, optional): Metadata object
- `policy_definition_reference_id` (string, optional): Single policy definition reference ID within a policy set
- `policy_definition_reference_ids` (list(string), optional): Multiple policy definition reference IDs within a policy set

**Note:** You cannot specify both `policy_definition_reference_id` and `policy_definition_reference_ids`. Use only one approach.
**Note:** Provide either `scope` or `scopes`, not both.

## Outputs
- `exemption_ids`: Map of exemption IDs keyed by exemption name
- `exemption_names`: List of all exemption names created
- `exemption_details`: Comprehensive details of all exemptions
- `exemption_id`: The ID of the first exemption (backward compatibility)
- `exemption_name`: The name of the first exemption (backward compatibility)
- `scope`: The scope of the policy exemption
- `scopes`: List of scopes for the policy exemptions
- `policy_assignment_id`: The policy assignment ID associated with the exemption
- `policy_definition_reference_ids`: List of reference IDs that were exempted
- `exemption_configuration`: Configuration details for all exemptions
- `exemption_category`: The exemption category used
- `expires_on`: The expiration date used

## Scope Detection
The module automatically detects the scope type using regex patterns:
- Management Group: `/providers/Microsoft.Management/managementGroups/{name}`
- Subscription: `/subscriptions/{subscription-id}`
- Resource Group: `/subscriptions/{subscription-id}/resourceGroups/{rg-name}`
- Resource: `/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/{provider}/{resource}`
