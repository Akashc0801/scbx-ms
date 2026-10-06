#################################################
# Outputs
#################################################

output "debug_api_level" {
  value = {
    for k, v in var.apis :
    k => {
      policy_template = lookup(v, "policy_template", null)
      policy_vars     = lookup(v, "policy_vars", null)
    }
  }
}
output "api_ids" {
  description = "IDs of created APIs"
  value       = { for k, v in azurerm_api_management_api.this : k => v.id }
}

output "api_names" {
  description = "Names of created APIs"
  value       = keys(azurerm_api_management_api.this)
}

output "api_version_set_ids" {
  description = "IDs of created version sets"
  value       = { for k, v in azurerm_api_management_api_version_set.this : k => v.id }
}

output "operation_ids" {
  description = "Operation IDs"
  value       = { for k, v in azurerm_api_management_api_operation.this : k => v.operation_id }
}
output "debug_operation_policies" {
  value = local.operation_policies
}