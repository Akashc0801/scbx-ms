output "logger_id" {
  description = "ID of the APIM logger"
  value       = azurerm_api_management_logger.this.id
}

output "logger_name" {
  description = "Name of the APIM logger"
  value       = azurerm_api_management_logger.this.name
}

output "api_management_name" {
  description = "APIM instance name used by the logger"
  value       = azurerm_api_management_logger.this.api_management_name
}