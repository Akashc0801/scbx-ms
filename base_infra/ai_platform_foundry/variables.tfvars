# Naming follows the SCB naming module: org-type-app_code-env-region_code-base_name-iterator.
# Values that are not yet known are left blank and must be completed before apply.
# Generated names (length-checked in checks.tf):
#   Foundry account   scb-aif-aiplatform-np-sea-foundry-001
#   Key Vault         scb-kv-aip-np-sea-fd-001            (24-character limit)
#   Storage account   scbstaipnpseafoundry001              (24-character limit, no dashes)
#   Cosmos DB         scb-cosmos-aiplatform-np-sea-foundry-001
#   AI Search         scb-srch-aiplatform-np-sea-foundry-001
#   Container reg.    scbacraiplatformnpseafoundry001
#   App Insights      scb-appi-aiplatform-np-sea-foundry-001
#   Log Analytics     scb-log-aiplatform-np-sea-foundry-001

common = {
  # Naming module variables
  org         = "scb"
  env         = "np"
  region_code = "sea"
  app_code    = "aiplatform"
  au          = "" # numeric accounting unit (required before plan)
  bu          = ""
  owner       = ""

  # Mandatory Tags
  environment         = "NPRD"
  business_owner      = ""
  business_unit       = ""
  criticality         = ""
  cost_center         = ""
  data_classification = ""
  compliance          = ""
  app_name            = "AI Platform Foundry"
  app_support         = "" # valid email address (required by Cosmos DB module)
  budget_id           = ""
  status              = "" # Live, Non-Operational or Decommissioned
  service             = "foundry"

  # Optional Tags
  region              = "southeastasia"
  description         = "AI Platform Foundry landing zone NPRD"
  notification_emails = []
  additional_tags     = {}
}

# Created by base_infra/ai_platform_network.
network = {
  resource_group_name                  = "scb-rg-aiplatform-np-sea-foundry-001"
  virtual_network_name                 = "scb-vnet-aiplatform-np-sea-foundry-001"
  virtual_network_resource_group_name  = "scb-rg-aiplatform-np-sea-foundry-001"
  agent_subnet_name                    = "az-snet-sbx-aiplatform-agent-nprd-001"
  private_endpoint_subnet_name         = "az-snet-sbx-aiplatform-foundrype-nprd-001"
  private_dns_zone_resource_group_name = "scb-rg-aiplatform-np-sea-aigw-001"
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
  app_code  = "aip"
  base_name = "fd"
  iterator  = "001"
  sku_name  = "standard"
}

storage_account = {
  app_code                 = "aip"
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
  app_code                = "aiplatform"
  base_name               = "foundry"
  iterator                = "001"
  zone_redundancy_enabled = true
}

foundry = {
  base_name    = "foundry"
  iterator     = "001"
  identity_key = "foundry"
  sku_name     = "S0"

  # Shared NPRD account, one project per use case.
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

nprd_values_verified = false
