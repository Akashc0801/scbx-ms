resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.scb_module_cosmos.name}"
  target_resource_id             = azurerm_cosmosdb_account.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.workspace_resource_id != null ? each.value.log_analytics_destination_type : null
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

# Lock is created after, and removed before, every other resource in this module
# so that Terraform can still update or destroy child resources.
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${module.scb_module_cosmos.name}")
  scope      = azurerm_cosmosdb_account.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    azurerm_cosmosdb_sql_database.this,
    azurerm_cosmosdb_sql_container.this,
    azurerm_private_endpoint.this,
    azurerm_private_endpoint.this_unmanaged_dns_zone_groups,
    azurerm_private_endpoint_application_security_group_association.this,
    azurerm_monitor_diagnostic_setting.this,
  ]
}
