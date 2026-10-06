module "scb_module_fwp" {
  source = "../../scb_naming_module/v1.0.0.1"

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
      ProductName        = "scb_firewall_policy"
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


resource "azurerm_firewall_policy" "this" {
  location                          = module.scb_module_fwp.location
  name                              = module.scb_module_fwp.name
  resource_group_name               = var.resource_group_name
  auto_learn_private_ranges_enabled = var.firewall_policy_auto_learn_private_ranges_enabled
  base_policy_id                    = var.firewall_policy_base_policy_id
  private_ip_ranges                 = var.firewall_policy_private_ip_ranges
  sku                               = var.firewall_policy_sku
  sql_redirect_allowed              = var.firewall_policy_sql_redirect_allowed
  tags                              = merge(module.scb_module_fwp.tags, var.tags != null ? var.tags : {})
  threat_intelligence_mode          = var.firewall_policy_threat_intelligence_mode

  dynamic "dns" {
    for_each = var.firewall_policy_dns == null ? [] : [var.firewall_policy_dns]

    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = dns.value.servers
    }
  }
  dynamic "explicit_proxy" {
    for_each = var.firewall_policy_explicit_proxy == null ? [] : [var.firewall_policy_explicit_proxy]

    content {
      enable_pac_file = explicit_proxy.value.enable_pac_file
      enabled         = explicit_proxy.value.enabled
      http_port       = explicit_proxy.value.http_port
      https_port      = explicit_proxy.value.https_port
      pac_file        = explicit_proxy.value.pac_file
      pac_file_port   = explicit_proxy.value.pac_file_port
    }
  }
  dynamic "identity" {
    for_each = var.firewall_policy_identity == null ? [] : [var.firewall_policy_identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "insights" {
    for_each = var.firewall_policy_insights == null ? [] : [var.firewall_policy_insights]

    content {
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      enabled                            = insights.value.enabled
      retention_in_days                  = insights.value.retention_in_days

      dynamic "log_analytics_workspace" {
        for_each = insights.value.log_analytics_workspace == null ? [] : insights.value.log_analytics_workspace

        content {
          firewall_location = log_analytics_workspace.value.firewall_location
          id                = log_analytics_workspace.value.id
        }
      }
    }
  }
  dynamic "intrusion_detection" {
    for_each = var.firewall_policy_intrusion_detection == null ? [] : [var.firewall_policy_intrusion_detection]

    content {
      mode           = intrusion_detection.value.mode
      private_ranges = intrusion_detection.value.private_ranges

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides == null ? [] : intrusion_detection.value.signature_overrides

        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }
      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass == null ? [] : intrusion_detection.value.traffic_bypass

        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = traffic_bypass.value.description
          destination_addresses = traffic_bypass.value.destination_addresses
          destination_ip_groups = traffic_bypass.value.destination_ip_groups
          destination_ports     = traffic_bypass.value.destination_ports
          source_addresses      = traffic_bypass.value.source_addresses
          source_ip_groups      = traffic_bypass.value.source_ip_groups
        }
      }
    }
  }
  dynamic "threat_intelligence_allowlist" {
    for_each = var.firewall_policy_threat_intelligence_allowlist == null ? [] : [var.firewall_policy_threat_intelligence_allowlist]

    content {
      fqdns        = threat_intelligence_allowlist.value.fqdns
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
    }
  }
  dynamic "timeouts" {
    for_each = var.firewall_policy_timeouts == null ? [] : [var.firewall_policy_timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "tls_certificate" {
    for_each = var.firewall_policy_tls_certificate == null ? [] : [var.firewall_policy_tls_certificate]

    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }
}

# Assigning Roles to the Firewall Policy
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_firewall_policy.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.scb_module_fwp.name}"
  target_resource_id             = azurerm_firewall_policy.this.id
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

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_firewall_policy.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}