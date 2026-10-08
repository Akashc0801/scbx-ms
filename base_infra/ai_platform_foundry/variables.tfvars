# Naming follows the SCB naming module "workload" format, as in
# base_infra/ai_platform_network: org-type-app_code-base_name-env-iterator.
# Generated names (length-checked in checks.tf):
#   Foundry account   az-aif-dtx-aiplatform-foundry-dev-001
#   Key Vault         az-kv-dtx-aip-fd-dev-001                 (24-character limit)
#   Storage account   azstdtxaipfoundrydev001                  (24-character limit, no dashes)
#   Cosmos DB         az-cosmos-dtx-aiplatform-foundry-dev-001
#   AI Search         az-srch-dtx-aiplatform-foundry-dev-001
#   Container reg.    azacrdtxaiplatformfoundrydev001
#   App Insights      az-appi-dtx-aiplatform-foundry-dev-001
#   Log Analytics     az-log-dtx-aiplatform-foundry-dev-001
#   Identities        az-id-dtx-aiplatform-<base_name>-dev-001
# Values copied from base_infra/ai_platform_network (au, app_support) are
# placeholders and must be confirmed.

common = {
  # Naming module variables
  org                  = "az"
  env                  = "dev"
  app_code             = "dtx-aiplatform"
  naming_format        = "workload"
  location_region_code = "sea" # location only; no region in names
  au                   = "12345"
  bu                   = ""
  owner                = ""

  # Mandatory Tags
  environment         = "DEV"
  business_owner      = ""
  business_unit       = ""
  criticality         = ""
  cost_center         = ""
  data_classification = ""
  compliance          = ""
  app_name            = "AI Platform Foundry"
  app_support         = "abc@xyz.com"
  budget_id           = ""
  status              = "Live"
  service             = "foundry"

  # Optional Tags
  region              = "southeastasia"
  description         = "AI Platform Foundry landing zone (dev)"
  notification_emails = []
  additional_tags     = {}
}

# Created by base_infra/ai_platform_network.
network = {
  resource_group_name                  = "az-rg-dtx-aiplatform-foundry-dev-001"
  virtual_network_name                 = "az-vnet-dtx-aiplatform-foundry-dev-001"
  virtual_network_resource_group_name  = "az-rg-dtx-aiplatform-foundry-dev-001"
  agent_subnet_name                    = "az-snet-dtx-aiplatform-foundryagent-dev-001"
  private_endpoint_subnet_name         = "az-snet-dtx-aiplatform-foundrype-dev-001"
  private_dns_zone_resource_group_name = "az-rg-dtx-aiplatform-aigw-dev-001"
}

# Build sheet: CanNotDelete on every resource. Set to null for a sandbox that
# will be destroyed.
resource_lock = {
  kind = "CanNotDelete"
}

user_assigned_identities = {
  foundry = {
    base_name = "foundry"
    iterator  = "001"
  }
  usecase_001 = {
    base_name = "usecase"
    iterator  = "001"
  }
}

log_analytics_workspace = {
  base_name          = "foundry"
  iterator           = "001"
  sku                = "PerGB2018"
  retention_in_days  = 30
  internet_ingestion = false
  # Portal queries need this until Azure Monitor Private Link Scope is in place.
  internet_query = true
}

application_insights = {
  base_name         = "foundry"
  iterator          = "001"
  retention_in_days = 90
  # Ingestion stays public until Azure Monitor Private Link Scope is in place;
  # otherwise agent traces cannot reach Application Insights.
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  # The Foundry project connection uses the connection string.
  local_authentication_disabled = false
}

key_vault = {
  app_code  = "dtx-aip"
  base_name = "fd"
  iterator  = "001"
  sku_name  = "standard"
}

storage_account = {
  app_code                 = "dtx-aip"
  base_name                = "foundry"
  iterator                 = "001"
  account_replication_type = "ZRS"
}

cosmosdb_account = {
  base_name      = "foundry"
  iterator       = "001"
  serverless     = true
  zone_redundant = false
  backup_type    = "Continuous"
  backup_tier    = "Continuous7Days"
}

ai_search = {
  base_name       = "foundry"
  iterator        = "001"
  sku             = "standard"
  replica_count   = 1
  partition_count = 1
}

container_registry = {
  app_code                = "dtx-aiplatform"
  base_name               = "foundry"
  iterator                = "001"
  zone_redundancy_enabled = true
}

foundry = {
  base_name    = "foundry"
  iterator     = "001"
  identity_key = "foundry"
  sku_name     = "S0"

  # Shared dev account, one project per use case.
  projects = {
    "usecase-001" = {
      display_name          = "Use case 001"
      identity_key          = "usecase_001"
      user_group_object_ids = [] # Entra group object IDs for project developers
      user_role_definition  = "Azure AI User"
    }
  }

  rai_policies = {
    baseline = {
      name = "scb-rai-baseline"
      content_filters = [
        { name = "Hate", source = "Prompt", severity_threshold = "Medium" },
        { name = "Hate", source = "Completion", severity_threshold = "Medium" },
        { name = "Sexual", source = "Prompt", severity_threshold = "Medium" },
        { name = "Sexual", source = "Completion", severity_threshold = "Medium" },
        { name = "Selfharm", source = "Prompt", severity_threshold = "Medium" },
        { name = "Selfharm", source = "Completion", severity_threshold = "Medium" },
        { name = "Violence", source = "Prompt", severity_threshold = "Medium" },
        { name = "Violence", source = "Completion", severity_threshold = "Medium" },
        { name = "Jailbreak", source = "Prompt" },
        { name = "Indirect Attack", source = "Prompt" },
        { name = "Protected Material Text", source = "Completion" },
        { name = "Protected Material Code", source = "Completion", block_enabled = false },
      ]
    }
  }

  # Model deployments are added once the approved model list and deployment
  # type (data residency) are confirmed. Example:
  # deployments = {
  #   gpt41mini = {
  #     name            = "gpt-4.1-mini"
  #     sku_name        = "DataZoneStandard"
  #     capacity        = 10
  #     model_name      = "gpt-4.1-mini"
  #     model_version   = "2025-04-14"
  #     rai_policy_name = "scb-rai-baseline"
  #   }
  # }
  deployments = {}
}

