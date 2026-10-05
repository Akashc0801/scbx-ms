module "mbb_module_law" {
  source = "../../mbb_naming_module/v1.0.0.0"

  # Basic naming parameters
  env                = var.env
  org                = var.org
  region_code        = var.region_code
  base_name          = var.base_name
  additional_name    = var.additional_name
  iterator           = var.iterator
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = var.resource_type_code
  max_length         = var.max_length
  no_dashes          = var.no_dashes
  add_random         = var.add_random
  rnd_length         = var.rnd_length

  # Mandatory Business Tags
  app_name       = var.app_name
  app_support    = var.app_support
  business_unit  = var.business_unit
  country        = var.country
  business_owner = var.business_owner
  type           = var.type

  # Mandatory DevOps Tags
  product_name    = var.product_name
  product_version = var.product_version

  # Mandatory Finance Tags
  cost_center          = var.cost_center
  cost_allocation_unit = var.cost_allocation_unit
  budget_id            = var.budget_id
  budget_limit         = var.budget_limit
  cost_alert_threshold = var.cost_alert_threshold

  # Mandatory Governance Tags
  data_classification = var.data_classification
  compliance_required = var.compliance_required
  compliance          = var.compliance

  # Mandatory Operation Tags
  criticality = var.criticality
  environment = var.environment
  status      = var.status

  # Optional Tags
  delete_after        = var.delete_after
  tier                = var.tier
  app_id              = var.app_id
  auto_delete         = var.auto_delete
  auto_shutdown       = var.auto_shutdown
  description         = var.description
  backup_policy       = var.backup_policy
  disaster_recovery   = var.disaster_recovery
  notification_emails = var.notification_emails
  region              = var.region

  # Additional custom tags
  additional_tags = var.additional_tags
}

resource "azurerm_log_analytics_workspace" "this" {
  location                           = module.mbb_module_law.location
  name                               = module.mbb_module_law.name
  resource_group_name                = var.resource_group_name
  allow_resource_only_permissions    = var.log_analytics_workspace_allow_resource_only_permissions
  cmk_for_query_forced               = var.log_analytics_workspace_cmk_for_query_forced
  daily_quota_gb                     = var.log_analytics_workspace_daily_quota_gb
  internet_ingestion_enabled         = var.log_analytics_workspace_internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics_workspace_internet_query_enabled
  local_authentication_disabled      = var.log_analytics_workspace_local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  retention_in_days                  = var.log_analytics_workspace_retention_in_days
  sku                                = var.log_analytics_workspace_sku
  tags                               = merge(module.mbb_module_law.tags, var.tags != null ? var.tags : {})

  dynamic "identity" {
    for_each = var.log_analytics_workspace_identity == null ? [] : [var.log_analytics_workspace_identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "timeouts" {
    for_each = var.log_analytics_workspace_timeouts == null ? [] : [var.log_analytics_workspace_timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

