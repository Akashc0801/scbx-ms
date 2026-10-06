# Multi-Channel Alerts Example

This example demonstrates creating an Action Group with multiple receiver types for different notification channels.

## Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-multi-channel-example"
  location = "East US"
}

module "multi_channel_action_group" {
  source = "../../"

  name                = "ag-multi-channel"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "multichan"

  # Email notifications for the team
  email_receivers = [
    {
      name                    = "Primary Contact"
      email_address           = "alerts@example.com"
      use_common_alert_schema = true
    },
    {
      name                    = "Secondary Contact"
      email_address           = "alerts-backup@example.com"
      use_common_alert_schema = true
    }
  ]

  # SMS for on-call engineer
  sms_receivers = [
    {
      name         = "On-Call Engineer"
      country_code = "1"
      phone_number = "5551234567"
    }
  ]

  # Voice call for critical issues
  voice_receivers = [
    {
      name         = "Emergency Contact"
      country_code = "1"
      phone_number = "5559876543"
    }
  ]

  # Webhook to external monitoring system
  webhook_receivers = [
    {
      name                    = "External Monitor"
      service_uri             = "https://monitoring.example.com/webhook"
      use_common_alert_schema = true
    }
  ]

  tags = {
    Environment  = "Production"
    CriticalPath = "Yes"
    Team         = "Platform"
  }
}

output "action_group_id" {
  value = module.multi_channel_action_group.id
}
```

## Alert Routing Strategy

This example uses a layered notification approach:

1. **Email**: All alerts - provides detailed context and history
2. **SMS**: High severity alerts - ensures on-call engineer sees critical issues
3. **Voice**: Critical alerts only - for immediate attention required
4. **Webhook**: All alerts - integrates with external monitoring and ticketing systems

## Configuration Notes

- Use separate receivers for different severity levels by creating multiple action groups
- SMS and voice receivers are limited to specific countries
- Test webhooks before enabling in production
- Consider time zones for SMS/voice notifications
