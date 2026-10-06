output "remediation_ids" {
  description = "Map of remediation IDs keyed by remediation name."
  value       = { for remediation in local.azurerm_policy_remediation : remediation.name => remediation.id }
}

output "remediation_names" {
  description = "List of all remediation names created."
  value       = [for remediation in local.azurerm_policy_remediation : remediation.name]
}

output "remediation_details" {
  description = "Comprehensive details of all remediations created."
  value = {
    for remediation in local.azurerm_policy_remediation : remediation.name => {
      id   = remediation.id
      name = remediation.name
    }
  }
}

# Backward compatibility outputs (for single remediation use case)
output "remediation_id" {
  description = "The ID of the first policy remediation (for backward compatibility)."
  value       = length(local.azurerm_policy_remediation) > 0 ? local.azurerm_policy_remediation[0].id : null
}

output "remediation_name" {
  description = "The name of the first policy remediation (for backward compatibility)."
  value       = length(local.azurerm_policy_remediation) > 0 ? local.azurerm_policy_remediation[0].name : null
}

output "scope" {
  description = "The scope of the policy remediation."
  value       = var.scope
}

output "policy_assignment_id" {
  description = "The policy assignment ID associated with the remediation."
  value       = var.policy_assignment_id
}

output "policy_definition_reference_ids" {
  description = "List of policy definition reference IDs that were remediated."
  value       = length(var.policy_definition_reference_ids) > 0 ? var.policy_definition_reference_ids : (var.policy_definition_reference_id != null ? [var.policy_definition_reference_id] : [])
}

output "remediation_configuration" {
  description = "Configuration details for all remediations."
  value = {
    for remediation in local.azurerm_policy_remediation : remediation.name => {
      id                   = remediation.id
      name                 = remediation.name
      policy_assignment_id = var.policy_assignment_id
      discovery_mode       = var.resource_discovery_mode
      failure_percentage   = var.failure_percentage
      parallel_deployments = var.parallel_deployments
    }
  }
}

output "resource_discovery_mode" {
  description = "The resource discovery mode used by the remediation."
  value       = var.resource_discovery_mode
}

output "failure_percentage" {
  description = "The failure percentage threshold for the remediation."
  value       = var.failure_percentage
}

output "parallel_deployments" {
  description = "The number of parallel deployments for the remediation."
  value       = var.parallel_deployments
}
