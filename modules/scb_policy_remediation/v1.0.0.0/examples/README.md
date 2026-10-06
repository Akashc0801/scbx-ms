# Example: Policy Remediation for Kubernetes Security Controls

This example demonstrates how to use the `scb_policy_remediation` module to remediate non-compliant Kubernetes security policies at different scopes and with various configurations.

## 📁 Files in this Example

- **`main.tf`**: Complete working example with 5 different remediation scenarios
- **`variables.tf`**: Input variables for customization
- **`outputs.tf`**: Comprehensive outputs showing remediation details
- **`terraform.tf`**: Provider requirements

## 🚀 Quick Start

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## 📋 Example Scenarios Included

### 1. Basic Remediation (Resource Group Scope)
Simple remediation with minimal configuration:
```hcl
module "basic_rg_remediation" {
  source = "../"
  
  name                    = "remediate-kubernetes-basic"
  scope                   = azurerm_resource_group.aks_rg.id
  policy_assignment_id    = azurerm_resource_group_policy_assignment.kubernetes_security.id
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters        = ["East US"]
}
```

### 2. Advanced Remediation with Policy Reference
Targets specific policy within a policy set:

```hcl
```hcl
module "advanced_rg_remediation" {
  source = "../"

  name                           = "remediate-kubernetes-advanced"
  scope                         = azurerm_resource_group.aks_rg.id
  policy_assignment_id          = azurerm_resource_group_policy_assignment.kubernetes_security.id
  policy_definition_reference_id = "KubernetesClusterContainersShouldNotShareHostProcessIDOrHostIPCNamespace"
  
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters       = ["East US", "West US 2"]
  failure_percentage     = 0.1    # Allow 10% failure
  parallel_deployments   = 5      # Process 5 resources simultaneously
  resource_count         = 50     # Limit to 50 resources
}
```

### 3. Subscription Level Remediation
Remediate across entire subscription:
```hcl
module "subscription_remediation" {
  source = "../"

  name                    = "remediate-sql-security"
  scope                   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_assignment_id    = azurerm_subscription_policy_assignment.sql_security.id
  resource_discovery_mode = "ReEvaluateCompliance"
  failure_percentage      = 0.05   # Allow 5% failure
  parallel_deployments    = 10     # Process 10 resources simultaneously
  resource_count          = 100    # Limit to 100 resources
}
```

### 4. High-Throughput Remediation
Maximum performance configuration:
```hcl
module "high_throughput_remediation" {
  source = "../"

  name                    = "remediate-high-volume"
  scope                   = azurerm_resource_group.aks_rg.id
  policy_assignment_id    = azurerm_resource_group_policy_assignment.kubernetes_security.id
  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage      = 0.2    # Allow 20% failure for large batches
  parallel_deployments    = 30     # Maximum parallel deployments
  resource_count          = 500    # Large batch size
}
```

### 5. Conservative Remediation
Safe, sequential processing:
```hcl
module "conservative_remediation" {
  source = "../"

  name                    = "remediate-conservative"
  scope                   = azurerm_resource_group.aks_rg.id
  policy_assignment_id    = azurerm_resource_group_policy_assignment.kubernetes_security.id
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters        = ["East US"]
  failure_percentage      = 0.01   # Allow only 1% failure
  parallel_deployments    = 1      # Sequential processing
  resource_count          = 10     # Small batches
}
```

## 🎯 Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Azure CLI authenticated or service principal configured
- Permissions to:
  - Create resource groups
  - Create policy assignments
  - Create policy remediations
  - Assign managed identities (for DeployIfNotExists policies)

## ⚙️ Customization

You can customize the example by modifying variables in `terraform.tfvars`:

```hcl
resource_group_name = "my-custom-rg"
location           = "West Europe" 
environment        = "Development"
enable_management_group_example = true  # If you have MG permissions
```

## 📊 Outputs

The example provides comprehensive outputs showing:
- Remediation IDs and status for each example
- Resource group details
- Policy assignment information
- Provisioning states
- Configuration parameters used

## 🔧 Running the Example

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd modules/scb_policy_remediation/v1.0.0.0/examples
   ```

2. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Monitor remediations:**
   ```bash
   # View remediation status
   az policy remediation list --resource-group rg-aks-security-example
   
   # Check specific remediation
   az policy remediation show --name remediate-kubernetes-basic --resource-group rg-aks-security-example
   ```

4. **Clean up:**
   ```bash
   terraform destroy
   ```

## 📚 Additional Resources

- [Azure Policy Remediation Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources)
- [Azure Policy Effects](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects)
- [Azure Kubernetes Security Baseline](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline)

## 🐛 Troubleshooting

### Common Issues

1. **Insufficient Permissions:**
   - Ensure you have `Policy Contributor` role
   - For DeployIfNotExists policies, ensure managed identity has appropriate permissions

2. **Policy Assignment Not Found:**
   - Verify the policy assignment exists and is correctly referenced
   - Check the scope matches your intended target

3. **Remediation Stuck:**
   - Check failure percentage settings
   - Review Azure Activity Log for detailed error messages
   - Verify resources exist and are in expected state

## ✨ What You'll Learn

This example demonstrates:
- ✅ Multi-scope remediation patterns (Resource Group, Subscription)
- ✅ Policy set definition targeting with reference IDs
- ✅ Performance tuning with failure percentages and parallel deployments
- ✅ Resource limiting and batch processing
- ✅ Conservative vs. aggressive remediation strategies
- ✅ Comprehensive monitoring and output collection

Perfect for understanding how to implement policy remediations at scale in your Azure environment! 🚀
```