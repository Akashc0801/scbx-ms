# ================================
# Action Group Outputs
# ================================

output "id" {
  description = "The ID of the Action Group."
  value       = azurerm_monitor_action_group.this.id
}

output "name" {
  description = "The name of the Action Group."
  value       = azurerm_monitor_action_group.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Action Group exists."
  value       = azurerm_monitor_action_group.this.resource_group_name
}

output "short_name" {
  description = "The short name of the Action Group."
  value       = azurerm_monitor_action_group.this.short_name
}

output "enabled" {
  description = "Whether the Action Group is enabled."
  value       = azurerm_monitor_action_group.this.enabled
}

output "action_group" {
  description = "The complete Action Group resource object."
  value       = azurerm_monitor_action_group.this
  sensitive   = true
}
