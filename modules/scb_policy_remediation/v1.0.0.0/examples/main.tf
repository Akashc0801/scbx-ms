# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Data source for current subscription
data "azurerm_client_config" "current" {}

# Example Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "rg-aks-security-example"
  location = "East US"

  tags = {
    Environment = "Example"
    Purpose     = "PolicyRemediationDemo"
  }
}

# Example Management Group (if you have permissions)
# data "azurerm_management_group" "example" {
#   display_name = "YourManagementGroup"
# }

#
# Policy Assignment Examples (these would typically be created using scb_policy_assignment module)
# These are simplified examples - in practice you'd use your policy set definitions
#

# Example Policy Assignment at Resource Group scope
resource "azurerm_resource_group_policy_assignment" "kubernetes_security" {
  name                 = "kubernetes-security-controls"
  resource_group_id    = azurerm_resource_group.aks_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00" # Built-in Kubernetes cluster pod security baseline standards

  display_name = "Kubernetes Security Controls"
  description  = "Enforce Kubernetes security controls for container workloads"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })

  # Create managed identity for policies that require it
  identity {
    type = "SystemAssigned"
  }
}

# Example Policy Assignment at Subscription scope
resource "azurerm_subscription_policy_assignment" "sql_security" {
  name                 = "sql-security-controls"
  subscription_id      = data.azurerm_client_config.current.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/89c8a434-18f7-4ede-adb8-37d6f3b9cfd9" # Built-in SQL security initiative

  display_name = "SQL Security Controls"
  description  = "Enforce SQL security controls"

  parameters = jsonencode({
    effect = {
      value = "DeployIfNotExists"
    }
  })

  # Create managed identity for DeployIfNotExists policies
  identity {
    type = "SystemAssigned"
  }

  location = "East US"
}

#
# Policy Remediation Examples using scb_policy_remediation module
#

# Example 1: Basic Remediation at Resource Group scope
module "basic_rg_remediation" {
  source = "../"

  name                 = "remediate-kubernetes-basic"
  scope                = azurerm_resource_group.aks_rg.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.kubernetes_security.id

  # Basic configuration
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters        = ["East US"]
}

# Example 2: Advanced Remediation with Policy Set Reference
module "advanced_rg_remediation" {
  source = "../"

  name                           = "remediate-kubernetes-advanced"
  scope                          = azurerm_resource_group.aks_rg.id
  policy_assignment_id           = azurerm_resource_group_policy_assignment.kubernetes_security.id
  policy_definition_reference_id = "KubernetesClusterContainersShouldNotShareHostProcessIDOrHostIPCNamespace"

  # Advanced configuration
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters        = ["East US", "West US 2"]
  failure_percentage      = 0.1 # Allow 10% failure
  parallel_deployments    = 5   # Process 5 resources simultaneously
  resource_count          = 50  # Limit to 50 resources
}

# Example 3: Subscription Level Remediation
module "subscription_remediation" {
  source = "../"

  name                 = "remediate-sql-security"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  policy_assignment_id = azurerm_subscription_policy_assignment.sql_security.id

  # Configuration for subscription-wide remediation
  resource_discovery_mode = "ReEvaluateCompliance"
  failure_percentage      = 0.05 # Allow 5% failure
  parallel_deployments    = 10   # Process 10 resources simultaneously
  resource_count          = 100  # Limit to 100 resources
}

# Example 4: High-throughput Remediation
module "high_throughput_remediation" {
  source = "../"

  name                 = "remediate-high-volume"
  scope                = azurerm_resource_group.aks_rg.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.kubernetes_security.id

  # High-throughput configuration
  resource_discovery_mode = "ExistingNonCompliant"
  failure_percentage      = 0.2 # Allow 20% failure for large batches
  parallel_deployments    = 30  # Maximum parallel deployments
  resource_count          = 500 # Large batch size
}

# Example 5: Conservative Remediation
module "conservative_remediation" {
  source = "../"

  name                 = "remediate-conservative"
  scope                = azurerm_resource_group.aks_rg.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.kubernetes_security.id

  # Conservative configuration
  resource_discovery_mode = "ExistingNonCompliant"
  location_filters        = ["East US"]
  failure_percentage      = 0.01 # Allow only 1% failure
  parallel_deployments    = 1    # Sequential processing
  resource_count          = 10   # Small batches
}

# Example 6: Management Group Remediation (uncomment if you have MG permissions)
# module "management_group_remediation" {
#   source = "../"
#
#   name                           = "remediate-mg-policies"
#   scope                         = data.azurerm_management_group.example.id
#   policy_assignment_id          = azurerm_management_group_policy_assignment.example.id
#   policy_definition_reference_id = "DeployAKSPolicyAddOn"
#
#   # Management Group level configuration
#   location_filters      = ["East US", "West US 2", "West Europe"]
#   failure_percentage    = 0.1
#   parallel_deployments  = 20
#   resource_count        = 200
# }

#
# Outputs
#

output "remediation_details" {
  description = "Details of all created policy remediations"
  value = {
    basic_remediation = {
      id                        = module.basic_rg_remediation.remediation_id
      name                      = module.basic_rg_remediation.remediation_name
      remediation_configuration = module.basic_rg_remediation.remediation_configuration
    }
    advanced_remediation = {
      id                              = module.advanced_rg_remediation.remediation_id
      name                            = module.advanced_rg_remediation.remediation_name
      remediation_configuration       = module.advanced_rg_remediation.remediation_configuration
      policy_definition_reference_ids = module.advanced_rg_remediation.policy_definition_reference_ids
    }
    subscription_remediation = {
      id                        = module.subscription_remediation.remediation_id
      name                      = module.subscription_remediation.remediation_name
      remediation_configuration = module.subscription_remediation.remediation_configuration
      resource_discovery_mode   = module.subscription_remediation.resource_discovery_mode
    }
    high_throughput_remediation = {
      id                        = module.high_throughput_remediation.remediation_id
      name                      = module.high_throughput_remediation.remediation_name
      remediation_configuration = module.high_throughput_remediation.remediation_configuration
      parallel_deployments      = module.high_throughput_remediation.parallel_deployments
    }
    conservative_remediation = {
      id                        = module.conservative_remediation.remediation_id
      name                      = module.conservative_remediation.remediation_name
      remediation_configuration = module.conservative_remediation.remediation_configuration
      failure_percentage        = module.conservative_remediation.failure_percentage
    }
  }
}

output "resource_group_id" {
  description = "The ID of the example resource group"
  value       = azurerm_resource_group.aks_rg.id
}

output "subscription_id" {
  description = "The current subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}