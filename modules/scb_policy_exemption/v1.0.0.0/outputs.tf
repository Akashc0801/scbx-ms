output "exemption_ids" {
  description = "Map of exemption IDs keyed by exemption name."
  value       = { for exemption in local.azurerm_policy_exemption : exemption.name => exemption.id... }
}

output "exemption_names" {
  description = "List of all exemption names created."
  value       = [for exemption in local.azurerm_policy_exemption : exemption.name]
}

output "exemption_details" {
  description = "Comprehensive details of all exemptions created."
  value = {
    for exemption in local.azurerm_policy_exemption : exemption.name => {
      id   = exemption.id
      name = exemption.name
    }...
  }
}

# Backward compatibility outputs (for single exemption use case)
output "exemption_id" {
  description = "The ID of the first policy exemption (for backward compatibility)."
  value       = length(local.azurerm_policy_exemption) > 0 ? local.azurerm_policy_exemption[0].id : null
}

output "exemption_name" {
  description = "The name of the first policy exemption (for backward compatibility)."
  value       = length(local.azurerm_policy_exemption) > 0 ? local.azurerm_policy_exemption[0].name : null
}

output "scope" {
  description = "The scope of the policy exemption."
  value       = var.scope != null ? var.scope : (length(local.scopes_to_process) > 0 ? local.scopes_to_process[0] : null)
}

output "scopes" {
  description = "List of scopes for the policy exemptions."
  value       = local.scopes_to_process
}

output "policy_assignment_id" {
  description = "The policy assignment ID associated with the exemption."
  value       = var.policy_assignment_id
}

output "policy_definition_reference_ids" {
  description = "List of policy definition reference IDs that were exempted."
  value       = length(var.policy_definition_reference_ids) > 0 ? var.policy_definition_reference_ids : (var.policy_definition_reference_id != null ? [var.policy_definition_reference_id] : [])
}

output "exemption_configuration" {
  description = "Configuration details for all exemptions."
  value = {
    for exemption in local.azurerm_policy_exemption : exemption.name => {
      id                   = exemption.id
      name                 = exemption.name
      policy_assignment_id = var.policy_assignment_id
      exemption_category   = var.exemption_category
      expires_on           = var.expires_on
    }...
  }
}

output "exemption_category" {
  description = "The exemption category used by the exemption."
  value       = var.exemption_category
}

output "expires_on" {
  description = "The expiration date used by the exemption."
  value       = var.expires_on
}
