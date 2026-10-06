output "resource_group_id" {
  description = "The ID of the example resource group"
  value       = azurerm_resource_group.example.id
}

output "subscription_id" {
  description = "The current subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}
