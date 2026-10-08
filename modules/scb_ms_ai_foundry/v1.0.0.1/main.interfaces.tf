#################################
## Account diagnostic settings and locks
#################################
locals {
  # Flatten accounts x their diagnostic settings into a single map keyed by
  # "<account_key>.<diag_key>" so each setting becomes a discrete resource.
  ai_foundry_account_diagnostic_settings = merge([
    for acct_key, acct in(var.ai_foundry_accounts != null ? var.ai_foundry_accounts : {}) : {
      for diag_key, diag in acct.diagnostic_settings :
      "${acct_key}.${diag_key}" => {
        account_key = acct_key
        setting     = diag
      }
    }
  ]...)

  ai_foundry_account_locks = {
    for acct_key, acct in(var.ai_foundry_accounts != null ? var.ai_foundry_accounts : {}) :
    acct_key => acct.lock if acct.lock != null
  }
}

resource "azurerm_monitor_diagnostic_setting" "ai_foundry_account" {
  for_each = local.ai_foundry_account_diagnostic_settings

  name                           = each.value.setting.name != null ? each.value.setting.name : "diag-${azapi_resource.ai_foundry[each.value.account_key].name}"
  target_resource_id             = azapi_resource.ai_foundry[each.value.account_key].id
  log_analytics_workspace_id     = each.value.setting.workspace_resource_id
  log_analytics_destination_type = each.value.setting.workspace_resource_id != null ? each.value.setting.log_analytics_destination_type : null
  storage_account_id             = each.value.setting.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.setting.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.setting.event_hub_name
  partner_solution_id            = each.value.setting.marketplace_partner_resource_id

  dynamic "enabled_log" {
    for_each = each.value.setting.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.setting.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.setting.metric_categories

    content {
      category = metric.value
    }
  }
}

# The lock is created after, and removed before, every other resource in this
# module. A CanNotDelete lock on the account also blocks deleting its projects,
# deployments and connections, so Terraform must remove it first on destroy.
resource "azurerm_management_lock" "ai_foundry_account" {
  for_each = local.ai_foundry_account_locks

  lock_level = each.value.kind
  name       = coalesce(each.value.name, "lock-${azapi_resource.ai_foundry[each.key].name}")
  scope      = azapi_resource.ai_foundry[each.key].id
  notes      = each.value.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    module.project,
    module.deployment,
    module.rai_policy,
    module.account_connection,
    module.project_connection,
    module.capability_host,
    module.private_endpoint,
    module.rbac,
    azurerm_monitor_diagnostic_setting.ai_foundry_account,
  ]
}
