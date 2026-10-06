output "name" {
  description = "The name of the Container App."
  value       = azurerm_container_app.this.name
}

output "resource_id" {
  description = "The Azure resource ID of the Container App."
  value       = azurerm_container_app.this.id
}

output "identity" {
  description = "The identities assigned to the Container App."
  value       = azurerm_container_app.this.identity
}

output "latest_revision_name" {
  description = "The name of the latest revision of the Container App."
  value       = azurerm_container_app.this.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "The FQDN of the latest revision of the Container App."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "location" {
  description = "The Azure region where the Container App is located."
  value       = azurerm_container_app.this.location
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses of the Container App."
  value       = azurerm_container_app.this.outbound_ip_addresses
}

output "custom_domain_verification_id" {
  description = "The custom domain verification ID for the Container App."
  value       = azurerm_container_app.this.custom_domain_verification_id
}

# -
# - Container App Environment Outputs
# -
output "container_app_environment_id" {
  description = "The ID of the Container App Environment (created or provided)."
  value       = var.create_container_app_environment ? azurerm_container_app_environment.ca_env[0].id : data.azurerm_container_app_environment.ace_existing[0].id
}

output "container_app_environment_default_domain" {
  description = "The default domain of the Container App Environment."
  value       = var.create_container_app_environment ? azurerm_container_app_environment.ca_env[0].default_domain : null
}

output "container_app_environment_static_ip_address" {
  description = "The Static IP address of the Container App Environment."
  value       = var.create_container_app_environment ? azurerm_container_app_environment.ca_env[0].static_ip_address : null
}

output "identity_cae" {
  description = "The identities assigned to the Container App Environment."
  value       = var.create_container_app_environment ? azurerm_container_app_environment.ca_env[0].identity[0] : null
}
