output "name" {
  value       = local.resource_name
  description = "The generated name of the resource by the module."
}
output "location" {
  value       = try(local.location_names[local.effective_location_region_code], null)
  description = "Location name compliant with `Azure Regions`' names. The list can be fetched with `az account list-locations --query '[].name'`."

  precondition {
    condition     = local.effective_location_region_code != null
    error_message = "A location cannot be resolved: set region_code or location_region_code."
  }
}
output "tags" {
  value       = local.base_tags
  description = "Set of Azure tags for the resource."
}

output "random_suffix" {
  value       = local.random_suffix
  description = "Randomized piece of the name, if used, for any name manipulation."
}
