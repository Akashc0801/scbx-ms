[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Srishti Ahlawat |
| Reviewed By| Akash Choudhary, Amit Kumar |

# scb_policy_remediation

A reusable Terraform module to trigger Azure Policy Remediation for policy assignments or policy set assignments at various scopes (Management Group, Subscription, Resource Group, or Resource level).

## Features
- Supports remediation at multiple Azure scopes:
  - Management Group level
  - Subscription level 
  - Resource Group level
  - Resource level
- Automatic scope detection using regex patterns
- Support for single or multiple policy definition reference IDs within policy sets
- Configurable resource discovery mode and location filters
- Comprehensive outputs for integration

## Usage

### Remediate Multiple Policies in a Policy Set
```hcl
module "multiple_policy_remediation" {
  source                          = "../scb_policy_remediation/v1.0.0.0"
  name                           = "remediate-kubernetes-security"
  scope                          = azurerm_resource_group.example.id
  policy_assignment_id           = azurerm_resource_group_policy_assignment.example.id
  
  # Remediate multiple policies from the same policy set
  policy_definition_reference_ids = [
    "DeployAKSPolicyAddOn",
    "KubernetesPrivilegedContainers", 
    "KubernetesPrivilegeEscalation",
    "DeploySQLTDE"
  ]
  
  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage      = 0.1
  parallel_deployments    = 5
}
```

### Remediate Single Policy in a Policy Set
```hcl
module "single_policy_remediation" {
  source                         = "../scb_policy_remediation/v1.0.0.0"
  name                          = "remediate-aks-addon"
  scope                         = azurerm_resource_group.example.id
  policy_assignment_id          = azurerm_resource_group_policy_assignment.example.id
  policy_definition_reference_id = "DeployAKSPolicyAddOn"
  
  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage      = 0.1
  parallel_deployments   = 5
}
```
```

### Remediate at Subscription scope
```hcl
module "sub_policy_remediation" {
  source                         = "../scb_policy_remediation/v1.0.0.0"
  name                          = "remediate-subscription-policies"
  scope                         = "/subscriptions/12345678-1234-1234-1234-123456789012"
  policy_assignment_id          = azurerm_subscription_policy_assignment.example.id
  resource_discovery_mode       = "ReEvaluateCompliance"
  failure_percentage            = 0.05
  parallel_deployments          = 15
}
```

### Remediate at Resource Group scope (Advanced Configuration)
```hcl
module "rg_policy_remediation" {
  source                         = "../scb_policy_remediation/v1.0.0.0"
  name                          = "remediate-rg-aks-policies"
  scope                         = azurerm_resource_group.example.id
  policy_assignment_id          = azurerm_resource_group_policy_assignment.example.id
  policy_definition_reference_id = "KubernetesPrivilegedContainers"
  location_filters              = ["eastus"]
  resource_discovery_mode       = "ExistingNonCompliant"
  failure_percentage            = 0.2
  parallel_deployments          = 30
  resource_count                = 50
}
```

## Variables
- `name` (string, required): Base name for the remediation(s)
- `scope` (string, required): Scope for the remediation (auto-detects scope type)
- `policy_assignment_id` (string, required): Policy assignment ID to remediate
- `policy_definition_reference_id` (string, optional): Single policy definition reference ID within a policy set
- `policy_definition_reference_ids` (list(string), optional): Multiple policy definition reference IDs within a policy set
- `location_filters` (list(string), optional): List of resource locations to remediate
- `resource_discovery_mode` (string, optional): Resource discovery mode (default: `ExistingNonCompliant`)
- `failure_percentage` (number, optional): Percentage of failures allowed before cancellation (default: 0.1)
- `parallel_deployments` (number, optional): Number of parallel deployments (default: 10, max: 30)
- `resource_count` (number, optional): Maximum number of resources to remediate

**Note:** You cannot specify both `policy_definition_reference_id` and `policy_definition_reference_ids`. Use only one approach.

## Outputs
- `remediation_ids`: Map of remediation IDs keyed by remediation name
- `remediation_names`: List of all remediation names created
- `remediation_details`: Comprehensive details of all remediations
- `remediation_id`: The ID of the first remediation (backward compatibility)
- `remediation_name`: The name of the first remediation (backward compatibility)
- `scope`: The scope of the policy remediation
- `policy_assignment_id`: The policy assignment ID associated with the remediation
- `policy_definition_reference_ids`: List of reference IDs that were remediated
- `provisioning_states`: Map of provisioning states for all remediations
- `resource_discovery_mode`: The resource discovery mode used
- `failure_percentage`: The failure percentage threshold
- `parallel_deployments`: The number of parallel deployments

## Scope Detection
The module automatically detects the scope type using regex patterns:
- Management Group: `/providers/Microsoft.Management/managementGroups/{name}`
- Subscription: `/subscriptions/{subscription-id}`
- Resource Group: `/subscriptions/{subscription-id}/resourceGroups/{rg-name}`
- Resource: `/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/{provider}/{resource}`
