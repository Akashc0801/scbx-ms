# -
# - Container App Environment
# -
resource "azurerm_container_app_environment" "ca_env" {
  count = var.create_container_app_environment ? 1 : 0

  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
  location            = module.scb_module_ca.location
  tags                = module.scb_module_ca.tags

  dapr_application_insights_connection_string = var.container_app_environment_dapr_application_insights_connection_string
  infrastructure_resource_group_name          = var.container_app_environment_infrastructure_resource_group_name
  infrastructure_subnet_id                    = var.container_app_environment_infrastructure_subnet_id
  internal_load_balancer_enabled              = local.use_networking ? var.container_app_environment_internal_load_balancer_enabled : null
  log_analytics_workspace_id                  = var.container_app_environment_log_analytics_workspace_id
  logs_destination                            = var.container_app_environment_logs_destination
  mutual_tls_enabled                          = var.container_app_environment_mutual_tls_enabled
  public_network_access                       = var.container_app_environment_public_network_access
  zone_redundancy_enabled                     = local.use_networking ? var.container_app_environment_zone_redundancy_enabled : null

  dynamic "workload_profile" {
    for_each = var.container_app_environment_workload_profiles != null ? var.container_app_environment_workload_profiles : []

    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      maximum_count         = workload_profile.value.maximum_count
      minimum_count         = workload_profile.value.minimum_count
    }
  }

  dynamic "identity" {
    for_each = var.container_app_environment_identity != null ? { this = var.container_app_environment_identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

###Private Endpoint for ACE
resource "azurerm_private_endpoint" "ca_env_pe" {
  count = var.create_container_app_environment && var.container_app_environment_private_endpoint != null ? 1 : 0

  name                = var.container_app_environment_private_endpoint.name
  location            = var.container_app_environment_private_endpoint.location
  resource_group_name = var.container_app_environment_private_endpoint.resource_group_name
  subnet_id           = var.container_app_environment_private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.container_app_environment_private_endpoint.name}-psc"
    private_connection_resource_id = azurerm_container_app_environment.ca_env[0].id
    subresource_names              = ["managedEnvironments"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = var.container_app_environment_private_endpoint.private_dns_zone_ids
  }

  depends_on = [
    azurerm_container_app_environment.ca_env
  ]
}

# -
# - Role Assignments
# -
resource "azurerm_role_assignment" "rbac_cae" {
  for_each = var.role_assignments_cae

  principal_id                           = try(each.value.principal_id, null) != null && try(each.value.principal_id, "") != "" ? each.value.principal_id : azurerm_container_app_environment.ca_env[0].identity[0].principal_id
  scope                                  = each.value.scope
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  depends_on = [
    azurerm_container_app_environment.ca_env
  ]
}