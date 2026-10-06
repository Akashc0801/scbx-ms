# Key Vault Audit Logging Policy Assignment Example
# This example demonstrates how to assign an Azure policy set for diagnostic settings
# specifically targeting Key Vault resources only.

# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Data source to get current client configuration
data "azurerm_client_config" "current" {}

# Data source to get current subscription
data "azurerm_subscription" "current" {}

# Key Vault Audit Logging Policy Assignment
module "keyvault_audit_policy" {
  source = "../../" # Points to the scb_policy_assignment module

  name         = "KeyVault-Audit-Only"
  display_name = "Key Vault Audit Logging Only"
  description  = "Enable audit category group resource logging specifically for Key Vault resources"

  # Built-in Azure policy set for diagnostic settings  
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/f5b29bc4-feca-4cc6-a58a-772dd5e290a5"
  scope                = data.azurerm_subscription.current.id

  # Parameters based on the actual policy set definition
  parameters = {
    # Effect for the policy
    "effect" = {
      "value" = var.policy_effect
    }

    # Diagnostic setting name
    "diagnosticSettingName" = {
      "value" = var.diagnostic_setting_name
    }

    # Resource location list (use * for all locations)
    "resourceLocationList" = {
      "value" = var.resource_location_list
    }

    # Log Analytics workspace - dynamically constructed
    "logAnalytics" = {
      "value" = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.log_analytics_resource_group}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"
    }

    # Target only Key Vault resources (note: parameter name is resourceTypeList for policy sets)
    "resourceTypeList" = {
      "value" = ["microsoft.keyvault/vaults"]
    }
  }

  # Auto-remediation for Key Vault resources
  assign_identity  = true
  location         = var.policy_assignment_location
  enforcement_mode = var.policy_enforcement_mode
}

# Output the policy assignment details
output "policy_assignment_id" {
  description = "The ID of the Key Vault audit policy assignment"
  value       = module.keyvault_audit_policy.id
}

output "policy_principal_id" {
  description = "The Principal ID of the policy assignment identity"
  value       = module.keyvault_audit_policy.principal_id
}

output "current_subscription_id" {
  description = "Current subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}