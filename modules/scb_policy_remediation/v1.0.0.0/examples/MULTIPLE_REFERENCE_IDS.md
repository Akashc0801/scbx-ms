# Example: Multiple Policy Definition Reference IDs

This example demonstrates the new capability to remediate multiple policy definitions within the same policy set.

## Single vs Multiple Reference IDs

### Option 1: Remediate Multiple Policies (NEW)
```hcl
module "kubernetes_multiple_policies" {
  source = "../"

  name                 = "remediate-kubernetes-security"
  scope               = azurerm_resource_group.aks_rg.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.kubernetes_security.id

  # Remediate multiple policies from your policy set
  policy_definition_reference_ids = [
    "DeployAKSPolicyAddOn",
    "KubernetesPrivilegedContainers",
    "KubernetesPrivilegeEscalation", 
    "DeploySQLTDE"
  ]

  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage     = 0.1
  parallel_deployments   = 5
}
```

**This creates 4 separate remediation resources:**
- `remediate-kubernetes-security-deployakspolicyaddon`
- `remediate-kubernetes-security-kubernetesprivilegedcontainers`
- `remediate-kubernetes-security-kubernetesprivilegeescalation`
- `remediate-kubernetes-security-deploysqltde`

### Option 2: Remediate Single Policy (Original)
```hcl
module "kubernetes_single_policy" {
  source = "../"

  name                           = "remediate-aks-addon"
  scope                         = azurerm_resource_group.aks_rg.id
  policy_assignment_id          = azurerm_resource_group_policy_assignment.kubernetes_security.id
  policy_definition_reference_id = "DeployAKSPolicyAddOn"

  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage     = 0.1
  parallel_deployments   = 5
}
```

**This creates 1 remediation resource:**
- `remediate-aks-addon`

## Benefits of Multiple Reference IDs

✅ **Simplified Management**: One module call handles multiple policies
✅ **Consistent Configuration**: Same settings applied across all remediations
✅ **Granular Control**: Each policy gets its own remediation task
✅ **Independent Monitoring**: Track status of each policy separately
✅ **Parallel Execution**: Multiple policies remediated simultaneously

## Outputs with Multiple Remediations

```hcl
output "remediation_summary" {
  value = {
    all_ids         = module.kubernetes_multiple_policies.remediation_ids
    all_names       = module.kubernetes_multiple_policies.remediation_names
    detailed_status = module.kubernetes_multiple_policies.remediation_details
    reference_ids   = module.kubernetes_multiple_policies.policy_definition_reference_ids
  }
}
```

## Monitoring Multiple Remediations

```bash
# List all remediations in the resource group
az policy remediation list --resource-group rg-aks-security-example

# Check specific remediation status  
az policy remediation show \
  --name "remediate-kubernetes-security-deployakspolicyaddon" \
  --resource-group rg-aks-security-example
```