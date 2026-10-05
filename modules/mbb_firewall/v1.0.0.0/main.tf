module "mbb_module_afw" {
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

  # Optional Tags (pass through if provided)
  delete_after        = var.delete_after
  tier                = var.tier
  app_id              = var.app_id
  auto_delete         = var.auto_delete
  auto_shutdown       = var.autoshutdown
  description         = var.description
  disaster_recovery   = var.disaster_recovery
  notification_emails = var.notification_emails
  region              = var.region
}

# trunk-ignore(checkov/CKV_AZURE_216)
resource "azurerm_firewall" "this" {
  location            = module.mbb_module_afw.location
  name                = module.mbb_module_afw.name
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = var.firewall_policy_id # Policy must have threat_intelligence_mode=Deny to comply with CKV_AZURE_216
  private_ip_ranges   = var.firewall_private_ip_ranges
  tags                = var.tags
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

  name                           = each.value.name != null ? each.value.name : "diag-${module.mbb_module_afw.name}"
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