# Complete Example with All Receiver Types

This example demonstrates using all available receiver types in a comprehensive monitoring setup.

## Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-complete-action-group"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-monitoring"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "logic-alert-processor"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_logic_app_trigger_http_request" "example" {
  name         = "manual-trigger"
  logic_app_id = azurerm_logic_app_workflow.example.id

  schema = <<SCHEMA
{
  "type": "object",
  "properties": {
    "data": {
      "type": "object"
    }
  }
}
SCHEMA
}

resource "azurerm_automation_account" "example" {
  name                = "aa-remediation"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Basic"
}

module "comprehensive_action_group" {
  source = "../../"

  name                = "ag-comprehensive"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "comprehensive"
  enabled             = true

  # ARM Role Receivers - notify users with specific Azure roles
  arm_role_receivers = [
    {
      name                    = "Subscription Owners"
      role_id                 = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
      use_common_alert_schema = true
    }
  ]

  # Email Receivers - standard email notifications
  email_receivers = [
    {
      name                    = "Operations Team"
      email_address           = "ops@example.com"
      use_common_alert_schema = true
    },
    {
      name                    = "Management"
      email_address           = "mgmt@example.com"
      use_common_alert_schema = true
    }
  ]

  # SMS Receivers - urgent text notifications
  sms_receivers = [
    {
      name         = "On-Call Primary"
      country_code = "1"
      phone_number = "5551234567"
    },
    {
      name         = "On-Call Secondary"
      country_code = "1"
      phone_number = "5559876543"
    }
  ]

  # Voice Receivers - critical phone calls
  voice_receivers = [
    {
      name         = "Emergency Contact"
      country_code = "1"
      phone_number = "5551112222"
    }
  ]

  # Webhook Receivers - external system integration
  webhook_receivers = [
    {
      name                    = "Monitoring Dashboard"
      service_uri             = "https://dashboard.example.com/api/alerts"
      use_common_alert_schema = true
    },
    {
      name                    = "SIEM System"
      service_uri             = "https://siem.example.com/ingest"
      use_common_alert_schema = true
      aad_auth = {
        object_id      = "12345678-1234-1234-1234-123456789012"
        identifier_uri = "https://siem.example.com"
      }
    }
  ]

  # Logic App Receivers - workflow automation
  logic_app_receivers = [
    {
      name                    = "Alert Workflow"
      resource_id             = azurerm_logic_app_workflow.example.id
      callback_url            = azurerm_logic_app_trigger_http_request.example.callback_url
      use_common_alert_schema = true
    }
  ]

  # Azure Function Receivers - serverless processing
  azure_function_receivers = [
    {
      name                     = "Alert Enrichment"
      function_app_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-functions/providers/Microsoft.Web/sites/func-alerts"
      function_name            = "EnrichAlert"
      http_trigger_url         = "https://func-alerts.azurewebsites.net/api/EnrichAlert"
      use_common_alert_schema  = true
    }
  ]

  # Automation Runbook Receivers - automated remediation
  automation_runbook_receivers = [
    {
      name                    = "Auto Scale"
      automation_account_id   = azurerm_automation_account.example.id
      runbook_name            = "ScaleResources"
      webhook_resource_id     = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-automation/providers/Microsoft.Automation/automationAccounts/aa-remediation/webhooks/webhook1"
      is_global_runbook       = false
      service_uri             = "https://webhook.automation.azure.com/webhooks?token=..."
      use_common_alert_schema = true
    }
  ]

  # Event Hub Receivers - stream to event processing
  event_hub_receivers = [
    {
      name                    = "Alert Stream"
      event_hub_namespace     = "evhns-monitoring"
      event_hub_name          = "alerts"
      use_common_alert_schema = true
    }
  ]

  # Azure App Push Receivers - mobile notifications
  azure_app_push_receivers = [
    {
      name          = "Mobile Admin"
      email_address = "admin@example.com"
    }
  ]

  tags = {
    Environment  = "Production"
    CriticalPath = "Yes"
    Team         = "Platform Engineering"
    CostCenter   = "IT-Ops"
  }
}

output "action_group_id" {
  description = "The ID of the comprehensive Action Group"
  value       = module.comprehensive_action_group.id
}

output "action_group_name" {
  description = "The name of the Action Group"
  value       = module.comprehensive_action_group.name
}

output "short_name" {
  description = "The short name used in notifications"
  value       = module.comprehensive_action_group.short_name
}
```

## Alert Flow Architecture

This comprehensive setup creates a multi-tier notification and response system:

```
Azure Alert Triggered
        |
        v
    Action Group
        |
        +-- ARM Role Receivers --> Owners notified via email/portal
        |
        +-- Email Receivers --> Operations team and management
        |
        +-- SMS Receivers --> On-call engineers (urgent)
        |
        +-- Voice Receivers --> Emergency contacts (critical)
        |
        +-- Webhook Receivers --> External monitoring systems
        |
        +-- Logic App --> Complex workflow automation
        |
        +-- Azure Function --> Real-time alert processing
        |
        +-- Automation Runbook --> Automated remediation
        |
        +-- Event Hub --> Stream to analytics platform
        |
        +-- Azure App Push --> Mobile notifications
```

## Use Cases by Receiver Type

### Informational Alerts (Low Severity)
- Email Receivers
- Azure App Push Receivers
- Event Hub Receivers

### Warning Alerts (Medium Severity)
- Email Receivers
- SMS Receivers
- Webhook Receivers
- Logic App Receivers

### Critical Alerts (High Severity)
- All receiver types
- Voice Receivers for immediate attention
- Automation Runbook for auto-remediation
- ARM Role Receivers to escalate to management

## Configuration Notes

1. **Receiver Limits**: Azure enforces limits on the number of each receiver type per action group
2. **Notification Throttling**: Multiple alerts may be grouped to prevent notification spam
3. **Retry Logic**: Failed notifications are retried automatically
4. **Cost Consideration**: SMS and voice calls incur charges
5. **Testing**: Use the "Test action group" feature in Azure Portal before production use

## Best Practices

1. **Layer Notifications**: Use different channels for different severities
2. **Avoid Duplication**: Don't send the same person notifications via multiple channels for the same alert
3. **Use Common Alert Schema**: Standardizes processing across all receivers
4. **Monitor Delivery**: Check Action Group metrics to ensure notifications are delivered
5. **Regular Testing**: Test all receivers quarterly to ensure they still work
6. **Document Receivers**: Maintain documentation of who receives what and why
7. **Rotation Schedule**: Keep on-call schedules updated for SMS/voice receivers
