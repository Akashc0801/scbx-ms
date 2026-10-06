#
# - Naming Module - Generates standardized resource name and tags
#
module "scb_module_mag" {
  source = "../../scb_naming_module/v1.0.0.1"

  env                 = var.env
  au                  = var.au
  org                 = var.org
  owner               = var.owner
  app_code            = var.app_code
  bu                  = var.bu
  resource_type_code  = var.resource_type_code
  additional_name     = var.additional_name
  iterator            = var.iterator
  max_length          = var.max_length
  region_code         = var.region_code
  product_version     = "1.0.0.0"
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails
  additional_tags     = var.additional_tags
}

#
# - Create Azure Monitor Action Group
# - Defines notifications and actions when alerts are triggered
#
resource "azurerm_monitor_action_group" "this" {
  name                = module.scb_module_mag.name
  resource_group_name = var.resource_group_name
  short_name          = var.short_name
  enabled             = var.enabled
  location            = "global"
  tags                = module.scb_module_mag.tags

  # ARM Role Receivers - Send notifications to Azure RBAC roles
  dynamic "arm_role_receiver" {
    for_each = var.arm_role_receivers != null ? var.arm_role_receivers : []
    content {
      name                    = arm_role_receiver.value.name
      role_id                 = arm_role_receiver.value.role_id
      use_common_alert_schema = arm_role_receiver.value.use_common_alert_schema
    }
  }

  # Automation Runbook Receivers - Trigger Azure Automation runbooks
  dynamic "automation_runbook_receiver" {
    for_each = var.automation_runbook_receivers != null ? var.automation_runbook_receivers : []
    content {
      name                    = automation_runbook_receiver.value.name
      automation_account_id   = automation_runbook_receiver.value.automation_account_id
      runbook_name            = automation_runbook_receiver.value.runbook_name
      webhook_resource_id     = automation_runbook_receiver.value.webhook_resource_id
      is_global_runbook       = automation_runbook_receiver.value.is_global_runbook
      service_uri             = automation_runbook_receiver.value.service_uri
      use_common_alert_schema = automation_runbook_receiver.value.use_common_alert_schema
    }
  }

  # Azure App Push Receivers - Send notifications to Azure mobile app
  dynamic "azure_app_push_receiver" {
    for_each = var.azure_app_push_receivers != null ? var.azure_app_push_receivers : []
    content {
      name          = azure_app_push_receiver.value.name
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  # Azure Function Receivers - Trigger Azure Functions
  dynamic "azure_function_receiver" {
    for_each = var.azure_function_receivers != null ? var.azure_function_receivers : []
    content {
      name                     = azure_function_receiver.value.name
      function_app_resource_id = azure_function_receiver.value.function_app_resource_id
      function_name            = azure_function_receiver.value.function_name
      http_trigger_url         = azure_function_receiver.value.http_trigger_url
      use_common_alert_schema  = azure_function_receiver.value.use_common_alert_schema
    }
  }

  # Email Receivers - Send email notifications
  dynamic "email_receiver" {
    for_each = var.email_receivers != null ? var.email_receivers : []
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  # Event Hub Receivers - Send alerts to Event Hub
  dynamic "event_hub_receiver" {
    for_each = var.event_hub_receivers != null ? var.event_hub_receivers : []
    content {
      name                    = event_hub_receiver.value.name
      event_hub_namespace     = event_hub_receiver.value.event_hub_namespace
      event_hub_name          = event_hub_receiver.value.event_hub_name
      subscription_id         = event_hub_receiver.value.subscription_id
      tenant_id               = event_hub_receiver.value.tenant_id
      use_common_alert_schema = event_hub_receiver.value.use_common_alert_schema
    }
  }

  # ITSM Receivers - Send to ITSM tools (ServiceNow, etc.)
  dynamic "itsm_receiver" {
    for_each = var.itsm_receivers != null ? var.itsm_receivers : []
    content {
      name                 = itsm_receiver.value.name
      workspace_id         = itsm_receiver.value.workspace_id
      connection_id        = itsm_receiver.value.connection_id
      ticket_configuration = itsm_receiver.value.ticket_configuration
      region               = itsm_receiver.value.region
    }
  }

  # Logic App Receivers - Trigger Azure Logic Apps
  dynamic "logic_app_receiver" {
    for_each = var.logic_app_receivers != null ? var.logic_app_receivers : []
    content {
      name                    = logic_app_receiver.value.name
      resource_id             = logic_app_receiver.value.resource_id
      callback_url            = logic_app_receiver.value.callback_url
      use_common_alert_schema = logic_app_receiver.value.use_common_alert_schema
    }
  }

  # SMS Receivers - Send SMS text messages
  dynamic "sms_receiver" {
    for_each = var.sms_receivers != null ? var.sms_receivers : []
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  # Voice Receivers - Make phone calls
  dynamic "voice_receiver" {
    for_each = var.voice_receivers != null ? var.voice_receivers : []
    content {
      name         = voice_receiver.value.name
      country_code = voice_receiver.value.country_code
      phone_number = voice_receiver.value.phone_number
    }
  }

  # Webhook Receivers - Send HTTP POST to custom endpoints
  dynamic "webhook_receiver" {
    for_each = var.webhook_receivers != null ? var.webhook_receivers : []
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = webhook_receiver.value.use_common_alert_schema

      dynamic "aad_auth" {
        for_each = webhook_receiver.value.aad_auth != null ? [webhook_receiver.value.aad_auth] : []
        content {
          object_id      = aad_auth.value.object_id
          identifier_uri = aad_auth.value.identifier_uri
          tenant_id      = aad_auth.value.tenant_id
        }
      }
    }
  }
}
