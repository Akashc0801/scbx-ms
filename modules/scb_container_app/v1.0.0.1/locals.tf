locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  identity_type = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : (
    var.managed_identities.system_assigned ? "SystemAssigned" : (
      length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : null
    )
  )

  use_networking = var.container_app_environment_infrastructure_subnet_id != null

}
