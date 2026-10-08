locals {
  # Extract resource group name from resource group ID
  resource_group_name = split("/", var.resource_group_id)[4]
}

module "scb_module_bas" {
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

  # 8 Mandatory Tags for v1.0.0.1 naming module
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # 3 Optional Tags for v1.0.0.1 naming module
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
      ProductName        = "scb_bastion_host"
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

resource "azapi_resource" "bastion" {
  count = var.sku == "Developer" ? 0 : 1

  location  = module.scb_module_bas.location
  name      = module.scb_module_bas.name
  parent_id = var.resource_group_id
  type      = "Microsoft.Network/bastionHosts@2024-05-01"
  body = {
    sku = {
      name = var.sku
    }
    zones = var.zones
    properties = {
      disableCopyPaste         = !var.copy_paste_enabled
      enableFileCopy           = var.file_copy_enabled
      enableIpConnect          = var.ip_connect_enabled
      enableKerberos           = var.kerberos_enabled
      enablePrivateOnlyBastion = var.private_only_enabled
      enableSessionRecording   = var.session_recording_enabled
      enableShareableLink      = var.shareable_link_enabled
      enableTunneling          = var.tunneling_enabled
      ipConfigurations = [
        {
          name = coalesce(var.ip_configuration.name, "ipconfig-${module.scb_module_bas.name}")
          properties = {
            privateIPAllocationMethod = "Dynamic"
            publicIPAddress           = local.public_ip_resource_id
            subnet = {
              id = var.ip_configuration.subnet_id
            }
          }
        }
      ]
      scaleUnits = var.scale_units
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  replace_triggers_external_values = [
    var.sku
  ]
  response_export_values = ["properties.dnsName"]
  tags                   = merge(module.scb_module_bas.tags, var.tags != null ? var.tags : {})
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    precondition {
      condition     = var.private_only_enabled != true ? sort(local.public_ip_zone_config) == sort(var.zones) : true
      error_message = "The number of zones in the public IP address must match the number of zones in the Azure Bastion Host."
    }
  }
}

resource "azapi_resource" "bastion_developer" {
  count = var.sku == "Developer" ? 1 : 0

  location  = module.scb_module_bas.location
  name      = module.scb_module_bas.name
  parent_id = var.resource_group_id
  type      = "Microsoft.Network/bastionHosts@2024-05-01"
  body = {
    sku = {
      name = var.sku
    }
    properties = {
      virtualNetwork = {
        id = var.virtual_network_id
      }
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["properties.dnsName"]
  tags                   = merge(module.scb_module_bas.tags, var.tags != null ? var.tags : {})
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = var.sku == "Developer" ? azapi_resource.bastion_developer[0].id : azapi_resource.bastion[0].id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.scb_module_bas.name}"
  target_resource_id             = var.sku == "Developer" ? azapi_resource.bastion_developer[0].id : azapi_resource.bastion[0].id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
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


# trunk-ignore(checkov/CKV_1)
module "public_ip_address" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.0"
  count   = var.ip_configuration != null ? (var.ip_configuration.create_public_ip == true ? 1 : 0) : var.sku == "Developer" ? 0 : 1

  location            = module.scb_module_bas.location
  name                = coalesce(var.ip_configuration.public_ip_address_name, "pip-${module.scb_module_bas.name}")
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  sku                 = "Standard"
  tags = var.ip_configuration.public_ip_tags != null ? (
    var.ip_configuration.public_ip_merge_with_module_tags) ? merge(
    module.scb_module_bas.tags, var.ip_configuration.public_ip_tags) : (
    var.ip_configuration.public_ip_tags) : (
  var.ip_configuration.public_ip_merge_with_module_tags) ? module.scb_module_bas.tags : {}
  zones = [for zone in var.zones : parseint(zone, 10)]
}

resource "azurerm_management_lock" "pip" {
  count = var.lock != null && length(module.public_ip_address) > 0 ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}-pip")
  scope      = module.public_ip_address[0].resource_id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

data "azurerm_public_ip" "this" {
  count = var.ip_configuration != null ? (var.ip_configuration.create_public_ip == false && var.private_only_enabled == false ? 1 : 0) : 0

  name                = split("/", var.ip_configuration.public_ip_address_id)[length(split("/", var.ip_configuration.public_ip_address_id)) - 1]
  resource_group_name = split("/", var.ip_configuration.public_ip_address_id)[4]
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = var.sku == "Developer" ? azapi_resource.bastion_developer[0].id : azapi_resource.bastion[0].id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_role_assignment" "pip" {
  for_each = length(module.public_ip_address) > 0 ? var.role_assignments : {}

  principal_id                           = each.value.principal_id
  scope                                  = module.public_ip_address[0].resource_id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}