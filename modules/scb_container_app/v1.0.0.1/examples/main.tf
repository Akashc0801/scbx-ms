provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117"
    }
  }
}

# -
# - Resource Group
# -
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

# -
# - Call the Container App module using for_each
# -
module "container_app" {
  source   = "../"
  for_each = var.container_apps

  # Naming parameters
  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  region_code        = var.region_code
  resource_type_code = var.resource_type_code
  product_version    = var.product_version
  iterator           = each.value.iterator
  base_name          = each.value.base_name

  # Mandatory Business Tags
  business_unit  = var.business_unit
  business_owner = var.business_owner
  app_name       = "Container App - ${each.key}"
  app_support    = var.app_support
  budget_id      = var.budget_id
  criticality    = var.criticality
  environment    = var.environment

  # Resource configuration
  resource_group_name = azurerm_resource_group.this.name

  # Container App Environment
  create_container_app_environment                     = each.value.create_container_app_environment
  container_app_environment_name                       = each.value.container_app_environment_name
  container_app_environment_logs_destination           = each.value.container_app_environment_logs_destination
  container_app_environment_log_analytics_workspace_id = each.value.container_app_environment_log_analytics_workspace_id

  # Container App
  revision_mode = each.value.revision_mode
  template      = each.value.template
  ingress       = each.value.ingress
  registries    = each.value.registries
  secrets       = each.value.secrets
  dapr          = each.value.dapr

  managed_identities = each.value.managed_identities
}

# -
# - Outputs
# -
output "container_app_ids" {
  description = "Map of container app names to their resource IDs."
  value       = { for k, v in module.container_app : k => v.resource_id }
}

output "container_app_fqdns" {
  description = "Map of container app names to their latest revision FQDNs."
  value       = { for k, v in module.container_app : k => v.latest_revision_fqdn }
}

output "container_app_environment_ids" {
  description = "Map of container app names to their environment IDs."
  value       = { for k, v in module.container_app : k => v.container_app_environment_id }
}