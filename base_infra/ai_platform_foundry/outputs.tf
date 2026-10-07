output "user_assigned_identities" {
  description = "Identity names, resource IDs, principal IDs and client IDs keyed by identity key."
  value = {
    for k, v in module.user_assigned_identities : k => {
      name         = v.resource_name
      id           = v.resource_id
      principal_id = v.principal_id
      client_id    = v.client_id
    }
  }
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.log_analytics_workspace.resource_id
}

output "application_insights" {
  description = "Application Insights name and resource ID."
  value = {
    name = module.application_insights.name
    id   = module.application_insights.resource_id
  }
}

output "key_vault" {
  description = "Key Vault name, ID and URI."
  value = {
    name = module.key_vault.name
    id   = module.key_vault.resource_id
    uri  = module.key_vault.uri
  }
}

output "storage_account" {
  description = "Storage account name and ID."
  value = {
    name = module.storage_account.name
    id   = module.storage_account.resource_id
  }
}

output "cosmosdb_account" {
  description = "Cosmos DB account name, ID and endpoint."
  value = {
    name     = module.cosmosdb_account.name
    id       = module.cosmosdb_account.id
    endpoint = module.cosmosdb_account.endpoint
  }
}

output "ai_search" {
  description = "AI Search name and ID."
  value = {
    name = module.ai_search.resource.name
    id   = module.ai_search.resource_id
  }
}

output "container_registry" {
  description = "Container registry name and ID."
  value = {
    name = module.container_registry.name
    id   = module.container_registry.resource_id
  }
}

output "foundry" {
  description = "Foundry account ID, project IDs, deployment IDs and connection IDs."
  value = {
    account_id     = local.foundry_account_id
    project_ids    = module.foundry.ai_foundry_project_ids
    deployment_ids = module.foundry.ai_foundry_deployment_ids
    connection_ids = module.foundry.ai_foundry_project_connection_ids
  }
}
