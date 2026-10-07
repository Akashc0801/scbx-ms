locals {
  account_connections = var.account_connections != null ? var.account_connections : {}

  # Connection keys are not secret, but the map becomes sensitive when any
  # connection carries credentials. for_each cannot use sensitive values, so
  # iterate over the keys.
  account_connection_keys = toset(try(nonsensitive(keys(local.account_connections)), keys(local.account_connections)))
}

########################################
## Account-Level Connections
## (Shared to all projects via isSharedToAll)
## For Standard Agent: Storage, Search, Cosmos
########################################
resource "azapi_resource" "account_connection" {
  for_each = local.account_connection_keys

  type                      = "Microsoft.CognitiveServices/accounts/connections@2025-06-01"
  name                      = local.account_connections[each.key].name != null ? local.account_connections[each.key].name : each.key
  parent_id                 = var.account_ids[local.account_connections[each.key].account_key]
  schema_validation_enabled = false

  body = {
    properties = merge(
      {
        category      = local.account_connections[each.key].category
        target        = local.account_connections[each.key].target
        authType      = local.account_connections[each.key].auth_type
        isSharedToAll = local.account_connections[each.key].is_shared
      },
      length(local.account_connections[each.key].credentials) > 0 ? {
        credentials = local.account_connections[each.key].credentials
      } : {},
      length(local.account_connections[each.key].metadata) > 0 ? {
        metadata = local.account_connections[each.key].metadata
      } : {}
    )
  }
}

