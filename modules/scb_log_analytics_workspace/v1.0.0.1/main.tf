module "scb_module_law" {
  source = "../../scb_naming_module/v1.0.0.1"

  # Basic naming parameters
  env                  = var.env
  org                  = var.org
  region_code          = var.region_code
  location_region_code = var.location_region_code
  naming_format        = var.naming_format
  base_name            = var.base_name
  additional_name      = var.additional_name
  iterator             = var.iterator
  au                   = var.au
  app_code             = var.app_code
  bu                   = var.bu
  owner                = var.owner
  resource_type_code   = var.resource_type_code
  max_length           = var.max_length
  no_dashes            = var.no_dashes
  add_random           = var.add_random
  rnd_length           = var.rnd_length

  # Use v1.0.0.1 naming module interface
  product_version = "1.0.0.1"

  # Pass mandatory tags to naming module
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # Pass optional tags to naming module  
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails

  # Additional custom tags with ProductName and ProductVersion
  additional_tags = merge(
    var.additional_tags != null ? var.additional_tags : {},
    {
      # All the original v1.0.0.0 tags
      AppName            = var.app_name
      Type               = var.type
      ProductName        = "scb_log_analytics_workspace"
      ProductVersion     = "1.0.0.1"
      BudgetID           = var.budget_id
      BudgetLimit        = var.budget_limit
      CostAlertThreshold = var.cost_alert_threshold
      ComplianceRequired = var.compliance_required
      Status             = var.status
    },
    var.delete_after != "" ? { DeleteAfter = var.delete_after } : {},
    var.tier != "" ? { Tier = var.tier } : {},
    var.app_id != "" ? { AppId = var.app_id } : {},
    var.auto_delete != "" ? { AutoDelete = var.auto_delete } : {},
    var.auto_shutdown != "" ? { AutoShutdown = var.auto_shutdown } : {},
    var.backup_policy != "" ? { BackupPolicy = var.backup_policy } : {},
    var.disaster_recovery != "" ? { DisasterRecovery = var.disaster_recovery } : {},
    var.service != "" ? { Service = var.service } : {},
    var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.retention != "" ? { Retention = var.retention } : {},
    var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {},
    var.os != "" ? { OS = var.os } : {},
    var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {}
  )
}

resource "azurerm_log_analytics_workspace" "this" {
  location                           = module.scb_module_law.location
  name                               = module.scb_module_law.name
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
  tags                               = merge(module.scb_module_law.tags, var.tags != null ? var.tags : {})

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

