locals {
  c = var.common

  private_dns_zone_names = {
    cognitive          = "privatelink.cognitiveservices.azure.com"
    openai             = "privatelink.openai.azure.com"
    ai_services        = "privatelink.services.ai.azure.com"
    blob               = "privatelink.blob.core.windows.net"
    file               = "privatelink.file.core.windows.net"
    cosmos_sql         = "privatelink.documents.azure.com"
    search             = "privatelink.search.windows.net"
    key_vault          = "privatelink.vaultcore.azure.net"
    container_registry = "privatelink.azurecr.io"
  }

  dns_zone_ids = { for k, z in data.azurerm_private_dns_zone.this : k => z.id }

  diagnostics_to_law = {
    law = {
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  # Names the naming module should produce. Checked against Azure length
  # limits in checks.tf.
  expected_names = {
    key_vault          = join("-", [local.c.org, "kv", var.key_vault.app_code, local.c.env, local.c.region_code, var.key_vault.base_name, var.key_vault.iterator])
    storage_account    = join("", [local.c.org, "st", var.storage_account.app_code, local.c.env, local.c.region_code, var.storage_account.base_name, var.storage_account.iterator])
    container_registry = join("", [local.c.org, "acr", var.container_registry.app_code, local.c.env, local.c.region_code, var.container_registry.base_name, var.container_registry.iterator])
    ai_search          = join("-", [local.c.org, "srch", local.c.app_code, local.c.env, local.c.region_code, var.ai_search.base_name, var.ai_search.iterator])
    foundry            = join("-", [local.c.org, "aif", local.c.app_code, local.c.env, local.c.region_code, var.foundry.base_name, var.foundry.iterator])
  }

  foundry_account_key = "foundry"
  foundry_account_id  = module.foundry.ai_foundry_account_ids[local.foundry_account_key]

  # Endpoints used by the project connections.
  storage_blob_endpoint = "https://${module.storage_account.name}.blob.core.windows.net/"
  search_endpoint       = "https://${module.ai_search.resource.name}.search.windows.net"

  # Cosmos DB built-in data-plane role "Cosmos DB Built-in Data Contributor".
  cosmos_data_contributor_role_id = "${module.cosmosdb_account.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"

  # Connection names per project (one shared set of BYOR resources).
  connection_names = {
    cosmos  = module.cosmosdb_account.name
    storage = module.storage_account.name
    search  = module.ai_search.resource.name
    appi    = module.application_insights.name
  }

  # Roles the project identity needs before its capability host is created
  # (standard agent setup with your own resources).
  project_pre_caphost_roles = {
    cosmos_operator        = { role = "Cosmos DB Operator", scope = module.cosmosdb_account.id }
    storage_blob_contrib   = { role = "Storage Blob Data Contributor", scope = module.storage_account.resource_id }
    search_index_contrib   = { role = "Search Index Data Contributor", scope = module.ai_search.resource_id }
    search_service_contrib = { role = "Search Service Contributor", scope = module.ai_search.resource_id }
  }

  project_role_assignments = merge([
    for pk, p in var.foundry.projects : {
      for rk, r in local.project_pre_caphost_roles :
      "${pk}-${rk}" => {
        scope                = r.scope
        role_definition_name = r.role
        principal_id         = module.user_assigned_identities[p.identity_key].principal_id
      }
    }
  ]...)

  project_connections = merge([
    for pk, p in var.foundry.projects : merge(
      {
        "${pk}-cosmos" = {
          name        = local.connection_names.cosmos
          project_key = pk
          category    = "CosmosDb"
          target      = module.cosmosdb_account.endpoint
          auth_type   = "AAD"
          metadata    = { ApiType = "Azure", ResourceId = module.cosmosdb_account.id, location = data.azurerm_resource_group.foundry.location }
        }
        "${pk}-storage" = {
          name        = local.connection_names.storage
          project_key = pk
          category    = "AzureStorageAccount"
          target      = local.storage_blob_endpoint
          auth_type   = "AAD"
          metadata    = { ApiType = "Azure", ResourceId = module.storage_account.resource_id, location = data.azurerm_resource_group.foundry.location }
        }
        "${pk}-appi" = {
          name            = local.connection_names.appi
          project_key     = pk
          category        = "AppInsights"
          target          = module.application_insights.resource_id
          auth_type       = "ApiKey"
          credentials_key = module.application_insights.connection_string
          metadata        = { ApiType = "Azure", ResourceId = module.application_insights.resource_id }
        }
      },
      p.vector_store_with_aisearch ? {
        "${pk}-search" = {
          name        = local.connection_names.search
          project_key = pk
          category    = "CognitiveSearch"
          target      = local.search_endpoint
          auth_type   = "AAD"
          metadata    = { ApiType = "Azure", ResourceId = module.ai_search.resource_id, location = data.azurerm_resource_group.foundry.location }
        }
      } : {}
    )
  ]...)

  project_capability_hosts = {
    for pk, p in var.foundry.projects : pk => {
      name                       = "caphost-${pk}"
      project_key                = pk
      storage_connections        = [local.connection_names.storage]
      thread_storage_connections = [local.connection_names.cosmos]
      vector_store_connections   = p.vector_store_with_aisearch ? [local.connection_names.search] : []
    }
  }

  # Applied after the capability host has created the enterprise_memory
  # database and the project's agent blob containers.
  project_cosmos_role_assignments = {
    for pk, p in var.foundry.projects : pk => {
      project_key         = pk
      cosmos_account_name = module.cosmosdb_account.name
      resource_group_name = data.azurerm_resource_group.foundry.name
      role_definition_id  = local.cosmos_data_contributor_role_id
      principal_id        = module.user_assigned_identities[p.identity_key].principal_id
      scope               = "${module.cosmosdb_account.id}/dbs/enterprise_memory"
    }
  }

  post_caphost_storage_role_assignments = {
    for pk, p in var.foundry.projects : pk => {
      project_key  = pk
      principal_id = module.user_assigned_identities[p.identity_key].principal_id
      scope        = module.storage_account.resource_id
    }
  }

  # Human access to projects (RBAC-006).
  project_user_role_assignments = merge([
    for pk, p in var.foundry.projects : {
      for gid in p.user_group_object_ids :
      "${pk}-${gid}" => {
        role_definition_name = p.user_role_definition
        principal_id         = gid
        principal_type       = "Group"
        scope                = module.foundry.ai_foundry_project_ids[pk]
      }
    }
  ]...)
}
