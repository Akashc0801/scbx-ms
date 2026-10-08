#################################
## Identities (Foundry account and one per project)
#################################
module "user_assigned_identities" {
  for_each = var.user_assigned_identities

  source = "../../modules/scb_user_managed_identity/v1.0.0.1"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "id"
  base_name            = each.value.base_name
  iterator             = each.value.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  lock = var.resource_lock
}

#################################
## Monitoring (LAW + Application Insights)
#################################
module "log_analytics_workspace" {
  source = "../../modules/scb_log_analytics_workspace/v1.0.0.1"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "log"
  base_name            = var.log_analytics_workspace.base_name
  iterator             = var.log_analytics_workspace.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  log_analytics_workspace_sku                           = var.log_analytics_workspace.sku
  log_analytics_workspace_retention_in_days             = var.log_analytics_workspace.retention_in_days
  log_analytics_workspace_internet_ingestion_enabled    = var.log_analytics_workspace.internet_ingestion
  log_analytics_workspace_internet_query_enabled        = var.log_analytics_workspace.internet_query
  log_analytics_workspace_local_authentication_disabled = var.log_analytics_workspace.local_authentication_off

  lock = var.resource_lock
}

module "application_insights" {
  source = "../../modules/scb_app_insights/v1.0.0.0"

  resource_group_name = data.azurerm_resource_group.foundry.name
  workspace_id        = module.log_analytics_workspace.resource_id

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "appi"
  base_name            = var.application_insights.base_name
  iterator             = var.application_insights.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  retention_in_days             = var.application_insights.retention_in_days
  internet_ingestion_enabled    = var.application_insights.internet_ingestion_enabled
  internet_query_enabled        = var.application_insights.internet_query_enabled
  local_authentication_disabled = var.application_insights.local_authentication_disabled

  lock = var.resource_lock
}

#################################
## Bring-your-own resources (Key Vault, Storage, Cosmos DB, AI Search, ACR)
#################################
module "key_vault" {
  source = "../../modules/scb_key_vault/v1.0.0.3"

  resource_group_name = data.azurerm_resource_group.foundry.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = var.key_vault.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "kv"
  base_name            = var.key_vault.base_name
  iterator             = var.key_vault.iterator
  no_dashes            = false

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  sku_name                      = var.key_vault.sku_name
  soft_delete_retention_days    = var.key_vault.soft_delete_retention_days
  public_network_access_enabled = false

  private_endpoints = {
    vault = {
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      private_dns_zone_resource_ids = [local.dns_zone_ids.key_vault]
    }
  }

  diagnostic_settings = local.diagnostics_to_law
  lock                = var.resource_lock
}

module "storage_account" {
  source = "../../modules/scb_storage_account/v1.0.0.1"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = var.storage_account.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "st"
  base_name            = var.storage_account.base_name
  iterator             = var.storage_account.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  account_replication_type        = var.storage_account.account_replication_type
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  private_endpoints = {
    # The module names every endpoint "pe-<account>" unless a name is given,
    # so blob and file would collide.
    blob = {
      name                          = "pe-${local.expected_names.storage_account}-blob"
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      subresource_name              = "blob"
      private_dns_zone_resource_ids = [local.dns_zone_ids.blob]
    }
    file = {
      name                          = "pe-${local.expected_names.storage_account}-file"
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      subresource_name              = "file"
      private_dns_zone_resource_ids = [local.dns_zone_ids.file]
    }
  }

  # scb_storage_account does not generate diagnostic setting names.
  diagnostic_settings_storage_account = { law = { name = "diag-account", workspace_resource_id = module.log_analytics_workspace.resource_id } }
  diagnostic_settings_blob            = { law = { name = "diag-blob", workspace_resource_id = module.log_analytics_workspace.resource_id } }
  diagnostic_settings_file            = { law = { name = "diag-file", workspace_resource_id = module.log_analytics_workspace.resource_id } }
  lock                                = var.resource_lock
}

module "cosmosdb_account" {
  source = "../../modules/scb_cosmosdb_account/v1.0.0.0"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "cosmos"
  base_name            = var.cosmosdb_account.base_name
  iterator             = var.cosmosdb_account.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  public_network_access_enabled = false
  local_authentication_disabled = true
  capabilities                  = var.cosmosdb_account.serverless ? ["EnableServerless"] : []

  geo_locations = [{
    location          = data.azurerm_resource_group.foundry.location
    failover_priority = 0
    zone_redundant    = var.cosmosdb_account.zone_redundant
  }]

  backup = {
    type = var.cosmosdb_account.backup_type
    tier = var.cosmosdb_account.backup_type == "Continuous" ? var.cosmosdb_account.backup_tier : null
  }

  private_endpoints = {
    sql = {
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      subresource_name              = "Sql"
      private_dns_zone_resource_ids = [local.dns_zone_ids.cosmos_sql]
    }
  }

  diagnostic_settings = local.diagnostics_to_law
  lock                = var.resource_lock
}

module "ai_search" {
  source = "../../modules/scb_ai_search/v1.0.0.1"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "srch"
  base_name            = var.ai_search.base_name
  iterator             = var.ai_search.iterator
  max_length           = 60
  no_dashes            = false

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  sku                           = var.ai_search.sku
  replica_count                 = var.ai_search.replica_count
  partition_count               = var.ai_search.partition_count
  public_network_access_enabled = false
  local_authentication_enabled  = false

  # Required by the SCB AI policy "Configure Azure AI Search services to
  # enforce customer-managed keys" (Deny): Search then rejects any index or
  # synonym map that is not encrypted with a customer-managed key.
  customer_managed_key_enforcement_enabled = true

  managed_identities = {
    system_assigned = true
  }

  private_endpoints = {
    search = {
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      private_dns_zone_resource_ids = [local.dns_zone_ids.search]
    }
  }

  diagnostic_settings = local.diagnostics_to_law
  lock                = var.resource_lock
}

module "container_registry" {
  source = "../../modules/scb_azure_container_registry/v1.0.0.0"

  resource_group_name = data.azurerm_resource_group.foundry.name

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = var.container_registry.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "acr"
  base_name            = var.container_registry.base_name
  iterator             = var.container_registry.iterator
  max_length           = 50

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  sku                           = "Premium"
  public_network_access_enabled = false
  admin_enabled                 = false
  data_endpoint_enabled         = true
  zone_redundancy_enabled       = var.container_registry.zone_redundancy_enabled

  private_endpoints = {
    registry = {
      subnet_resource_id            = data.azurerm_subnet.private_endpoint.id
      private_dns_zone_resource_ids = [local.dns_zone_ids.container_registry]
    }
  }

  diagnostic_settings = local.diagnostics_to_law
  lock                = var.resource_lock
}

#################################
## Microsoft Foundry account, projects, connections, capability hosts
#################################
module "foundry" {
  source = "../../modules/scb_ms_ai_foundry/v1.0.0.1"

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "aif"
  base_name            = var.foundry.base_name
  iterator             = var.foundry.iterator
  max_length           = 64
  no_dashes            = false # module default strips dashes; customSubDomainName must equal the name

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags

  ai_foundry_accounts = {
    (local.foundry_account_key) = {
      parent_id              = data.azurerm_resource_group.foundry.id
      sku_name               = var.foundry.sku_name
      identity_type          = "UserAssigned"
      identity_id            = module.user_assigned_identities[var.foundry.identity_key].resource_id
      disableLocalAuth       = true
      allowProjectManagement = true
      customSubDomainName    = local.expected_names.foundry
      publicNetworkAccess    = "Disabled"

      # Agents run in the delegated agent subnet (set at account creation).
      network_injections = [{
        scenario      = "agent"
        subnet_arm_id = data.azurerm_subnet.agent.id
      }]

      diagnostic_settings = local.diagnostics_to_law
      lock                = var.resource_lock
    }
  }

  ai_foundry_projects = {
    for pk, p in var.foundry.projects : pk => {
      name                = pk
      account_key         = local.foundry_account_key
      location            = data.azurerm_resource_group.foundry.location
      sku_name            = var.foundry.sku_name
      displayName         = p.display_name
      identity_type       = "UserAssigned"
      identity_id         = module.user_assigned_identities[p.identity_key].resource_id
      diagnostic_settings = local.diagnostics_to_law
    }
  }

  private_endpoint_config = {
    name                = "pe-${local.expected_names.foundry}"
    location            = data.azurerm_resource_group.foundry.location
    resource_group_name = data.azurerm_resource_group.foundry.name
    subnet_id           = data.azurerm_subnet.private_endpoint.id
    account_key         = local.foundry_account_key
    subresource_names   = ["account"]
    dns_zone_ids = [
      local.dns_zone_ids.cognitive,
      local.dns_zone_ids.openai,
      local.dns_zone_ids.ai_services,
    ]
  }

  ai_foundry_project_connections   = local.project_connections
  project_role_assignments         = local.project_role_assignments
  project_capability_hosts         = local.project_capability_hosts
  project_cosmos_role_assignments  = local.project_cosmos_role_assignments
  post_ch_storage_role_assignments = local.post_caphost_storage_role_assignments

  ai_foundry_rai_policy = {
    for rk, r in var.foundry.rai_policies : rk => {
      name             = r.name
      account_key      = local.foundry_account_key
      base_policy_name = r.base_policy_name
      mode             = r.mode
      content_filters  = r.content_filters
    }
  }

  # Private endpoints and DNS records of the bring-your-own resources must exist
  # before the capability host connects to them.
  depends_on = [
    module.cosmosdb_account,
    module.storage_account,
    module.ai_search,
  ]

  ai_foundry_deployments = {
    for dk, d in var.foundry.deployments : dk => {
      name            = d.name
      account_key     = local.foundry_account_key
      sku_name        = d.sku_name
      capacity        = d.capacity
      model_format    = d.model_format
      model_name      = d.model_name
      model_version   = d.model_version
      rai_policy_name = d.rai_policy_name
    }
  }
}

#################################
## Human access to projects (RBAC-006)
#################################
module "project_user_role_assignments" {
  source = "../../modules/scb_role_assignments/v1.0.0.0"

  role_assignments_azure_resource_manager = local.project_user_role_assignments
}
