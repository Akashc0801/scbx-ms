module "scb_module_afw" {
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
      ProductName        = "scb_firewall"
      ProductVersion     = "1.0.0.1"
      BudgetID           = var.budget_id
      BudgetLimit        = var.budget_limit
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
    var.automation_policy != "" ? { AutomationPolicy = var.automation_policy } : {},
    var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.review_required != "" ? { ReviewRequired = var.review_required } : {},
    var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {},
    var.service != "" ? { Service = var.service } : {},
    var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.os != "" ? { OS = var.os } : {},
    var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {}
  )
}

# trunk-ignore(checkov/CKV_AZURE_216)
resource "azurerm_firewall" "this" {
  location            = module.scb_module_afw.location
  name                = module.scb_module_afw.name
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = var.firewall_policy_id # Policy must have threat_intelligence_mode=Deny to comply with CKV_AZURE_216
  private_ip_ranges   = var.firewall_private_ip_ranges
  tags                = merge(module.scb_module_afw.tags, var.tags != null ? var.tags : {})
  zones               = var.firewall_zones

  dynamic "ip_configuration" {
    for_each = var.firewall_ip_configuration == null ? [] : var.firewall_ip_configuration

    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
      subnet_id            = ip_configuration.value.subnet_id
    }
  }
  dynamic "ip_configuration" {
    for_each = var.ip_configurations

    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
      subnet_id            = ip_configuration.value.subnet_id
    }
  }
  dynamic "management_ip_configuration" {
    for_each = var.firewall_management_ip_configuration == null ? [] : [var.firewall_management_ip_configuration]

    content {
      name                 = management_ip_configuration.value.name
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
      subnet_id            = management_ip_configuration.value.subnet_id
    }
  }
  dynamic "timeouts" {
    for_each = var.firewall_timeouts == null ? [] : [var.firewall_timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "virtual_hub" {
    for_each = var.firewall_virtual_hub == null ? [] : [var.firewall_virtual_hub]

    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }
}
# Assigning Roles to the Firewall based on the provided configurations.
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_firewall.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.scb_module_afw.name}"
  target_resource_id             = azurerm_firewall.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}


resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_firewall.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}