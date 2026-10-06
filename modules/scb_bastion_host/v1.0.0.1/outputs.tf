output "name" {
  description = "The resource name of the bastion host."
  value       = module.scb_module_bas.name
}

output "resource" {
  description = "The Azure Bastion Host resource."
  value       = var.sku == "Developer" ? azapi_resource.bastion_developer[0] : azapi_resource.bastion[0]
}

output "resource_id" {
  description = "The resource ID of the bastion host."
  value       = var.sku == "Developer" ? azapi_resource.bastion_developer[0].id : azapi_resource.bastion[0].id
}

output "location" {
  description = "The Azure region where the bastion host is deployed."
  value       = module.scb_module_bas.location
}

output "tags" {
  description = "The tags applied to the bastion host."
  value       = module.scb_module_bas.tags
}

output "dns_name" {
  description = "The DNS name of the bastion host."
  value       = var.sku == "Developer" ? azapi_resource.bastion_developer[0].output.properties.dnsName : azapi_resource.bastion[0].output.properties.dnsName
}

output "public_ip_address" {
  description = "The public IP address resource (if created)."
  value       = length(module.public_ip_address) > 0 ? module.public_ip_address[0] : null
}