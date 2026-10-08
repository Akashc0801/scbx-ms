variable "common" {
  description = "Naming-module inputs and tags shared by every resource in this stack. Per-resource blocks set only base_name, iterator and, where a name length limit applies, app_code. Default naming_format is workload: org-type-app_code-base_name-env[-region]-iterator."
  type = object({
    # Naming module variables
    org                  = string
    env                  = string
    app_code             = string
    naming_format        = optional(string, "workload")
    region_code          = optional(string) # included in names when set
    location_region_code = optional(string, "sea")
    au                   = string
    bu                   = string
    owner                = string

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    app_support         = string
    budget_id           = string
    status              = string
    service             = string

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])
    additional_tags     = optional(map(string), {})
  })
}

variable "network" {
  description = "Names of the resources created by base_infra/ai_platform_network that this stack deploys into."
  type = object({
    resource_group_name                  = string
    virtual_network_name                 = string
    virtual_network_resource_group_name  = string
    agent_subnet_name                    = string
    private_endpoint_subnet_name         = string
    private_dns_zone_resource_group_name = string
  })
}

variable "resource_lock" {
  description = "Management lock applied to every resource that supports one. Build sheet: CanNotDelete. Set to null in a sandbox that must be torn down."
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = {
    kind = "CanNotDelete"
  }
}

variable "user_assigned_identities" {
  description = "User-assigned managed identities. The key is referenced by foundry.identity_key and foundry.projects[*].identity_key."
  type = map(object({
    base_name = string
    iterator  = string
  }))
}

variable "log_analytics_workspace" {
  description = "Log Analytics workspace that receives diagnostics and backs Application Insights."
  type = object({
    base_name                = string
    iterator                 = string
    sku                      = optional(string, "PerGB2018")
    retention_in_days        = optional(number, 30)
    internet_ingestion       = optional(bool, false)
    internet_query           = optional(bool, true)
    local_authentication_off = optional(bool, true)
  })
}

variable "application_insights" {
  description = "Workspace-based Application Insights used for Foundry agent tracing (FD-N-008)."
  type = object({
    base_name                     = string
    iterator                      = string
    retention_in_days             = optional(number, 90)
    internet_ingestion_enabled    = optional(bool, true)
    internet_query_enabled        = optional(bool, true)
    local_authentication_disabled = optional(bool, false)
  })
}

variable "key_vault" {
  description = "Key Vault for the Foundry landing zone (FD-N-003). Name limit is 24 characters, so app_code is shortened."
  type = object({
    app_code                   = string
    base_name                  = string
    iterator                   = string
    sku_name                   = optional(string, "standard")
    soft_delete_retention_days = optional(number, 90)
  })
}

variable "storage_account" {
  description = "Storage account for agent files (FD-N-004). Name limit is 24 characters without dashes, so app_code is shortened."
  type = object({
    app_code                 = string
    base_name                = string
    iterator                 = string
    account_replication_type = optional(string, "ZRS")
  })
}

variable "cosmosdb_account" {
  description = "Cosmos DB for NoSQL account for agent threads (FD-N-005)."
  type = object({
    base_name      = string
    iterator       = string
    serverless     = optional(bool, true)
    zone_redundant = optional(bool, false)
    backup_type    = optional(string, "Continuous")
    backup_tier    = optional(string, "Continuous7Days")
  })
}

variable "ai_search" {
  description = "AI Search service for agent vector stores (FD-N-006)."
  type = object({
    base_name       = string
    iterator        = string
    sku             = optional(string, "standard")
    replica_count   = optional(number, 1)
    partition_count = optional(number, 1)
  })
}

variable "container_registry" {
  description = "Container registry for hosted agent and tool images (FD-N-007). Premium is required for private endpoints."
  type = object({
    app_code                = string
    base_name               = string
    iterator                = string
    zone_redundancy_enabled = optional(bool, true)
  })
}

variable "foundry" {
  description = "Microsoft Foundry account, projects, content filter policies and model deployments (FD-N-001, FD-N-002)."
  type = object({
    base_name    = string
    iterator     = string
    identity_key = string
    sku_name     = optional(string, "S0")

    projects = map(object({
      display_name          = string
      identity_key          = string
      user_group_object_ids = optional(list(string), [])
      user_object_ids       = optional(list(string), [])
      # Built-in "Foundry User" (formerly "Azure AI User"). The ID is used
      # because Microsoft renames Foundry roles.
      user_role_definition_id    = optional(string, "53ca6127-db72-4b80-b1b0-d745d6d5456d")
      vector_store_with_aisearch = optional(bool, true)
    }))

    rai_policies = optional(map(object({
      name             = string
      base_policy_name = optional(string, "Microsoft.DefaultV2")
      mode             = optional(string, "Default")
      content_filters = list(object({
        name               = string
        source             = string
        severity_threshold = optional(string)
        filter_enabled     = optional(bool, true)
        block_enabled      = optional(bool, true)
      }))
    })), {})

    deployments = optional(map(object({
      name            = string
      sku_name        = string
      capacity        = number
      model_format    = optional(string, "OpenAI")
      model_name      = string
      model_version   = string
      rai_policy_name = optional(string)
    })), {})
  })
}
