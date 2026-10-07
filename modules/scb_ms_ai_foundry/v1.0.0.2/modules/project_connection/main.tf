locals {
  project_connections = var.ai_foundry_project_connections != null ? var.ai_foundry_project_connections : {}

  # Connection keys are not secret, but the map becomes sensitive when any
  # connection carries credentials (for example an App Insights connection
  # string). for_each cannot use sensitive values, so iterate over the keys.
  project_connection_keys = toset(try(nonsensitive(keys(local.project_connections)), keys(local.project_connections)))
}

########################################
## AI Foundry Project Connections
## (Cosmos DB, AI Search, Storage, etc.)
########################################
resource "azapi_resource" "ai_foundry_project_connection" {
  for_each = local.project_connection_keys

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = local.project_connections[each.key].name
  parent_id                 = local.project_connections[each.key].project_key != null ? var.project_ids[local.project_connections[each.key].project_key] : local.project_connections[each.key].parent_id
  schema_validation_enabled = false

  body = {
    properties = merge(
      {
        category = local.project_connections[each.key].category
        target   = local.project_connections[each.key].target
        authType = local.project_connections[each.key].auth_type
      },
      local.project_connections[each.key].auth_type == "ApiKey" && local.project_connections[each.key].credentials_key != null ? {
        credentials = { key = local.project_connections[each.key].credentials_key }
      } : {},
      local.project_connections[each.key].auth_type == "AccountKey" && local.project_connections[each.key].credentials_key != null ? {
        credentials = { accountKey = local.project_connections[each.key].credentials_key }
      } : {},
      length(local.project_connections[each.key].metadata) > 0 ? {
        metadata = local.project_connections[each.key].metadata
      } : {}
    )
  }
}
