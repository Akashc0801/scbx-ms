output "client_id" {
  description = "This is the client id for the user assigned identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "This is the principal id for the user assigned identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "resource" {
  description = "The object of type User Assigned Identity that was created."
  value       = azurerm_user_assigned_identity.this
}

output "resource_id" {
  description = "This is the full output for the resource."
  value       = azurerm_user_assigned_identity.this.id
}

output "resource_name" {
  description = "The name of the User Assigned Identity that was created."
  value       = azurerm_user_assigned_identity.this.name
}

output "federated_identity_credential_ids" {
  description = "Map of federated identity credential IDs keyed by credential name."
  value       = { for k, v in azurerm_federated_identity_credential.this : k => v.id }
}

output "federated_identity_credential_names" {
  description = "Map of federated identity credential names keyed by credential name."
  value       = { for k, v in azurerm_federated_identity_credential.this : k => v.name }
}

output "role_assignment_ids" {
  description = "Map of role assignment IDs keyed by role assignment key."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "tenant_id" {
  description = "The ID of the Tenant which the Identity belongs to."
  value       = azurerm_user_assigned_identity.this.tenant_id
}
