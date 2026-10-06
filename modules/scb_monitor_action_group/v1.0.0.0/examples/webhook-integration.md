# Webhook Integration Example

This example shows various webhook configurations including Azure AD authentication.

## Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-webhook-example"
  location = "East US"
}

# Simple webhook without authentication
module "basic_webhook_action_group" {
  source = "../../"

  name                = "ag-basic-webhook"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "basicweb"

  webhook_receivers = [
    {
      name                    = "Simple Webhook"
      service_uri             = "https://api.example.com/alerts"
      use_common_alert_schema = true
    }
  ]

  tags = {
    Environment = "Development"
  }
}

# Webhook with Azure AD authentication
module "secure_webhook_action_group" {
  source = "../../"

  name                = "ag-secure-webhook"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "secureweb"

  webhook_receivers = [
    {
      name                    = "Authenticated API"
      service_uri             = "https://secure-api.example.com/alerts"
      use_common_alert_schema = true
      aad_auth = {
        object_id      = "12345678-1234-1234-1234-123456789012"
        identifier_uri = "https://secure-api.example.com"
        tenant_id      = "87654321-4321-4321-4321-210987654321"
      }
    }
  ]

  tags = {
    Environment = "Production"
    Security    = "High"
  }
}

# Multiple webhooks for different systems
module "multi_webhook_action_group" {
  source = "../../"

  name                = "ag-multi-webhook"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "multiweb"

  webhook_receivers = [
    {
      name                    = "SIEM Integration"
      service_uri             = "https://siem.example.com/ingest"
      use_common_alert_schema = true
    },
    {
      name                    = "Ticketing System"
      service_uri             = "https://tickets.example.com/api/alerts"
      use_common_alert_schema = false
    },
    {
      name                    = "Custom Dashboard"
      service_uri             = "https://dashboard.example.com/api/events"
      use_common_alert_schema = true
      aad_auth = {
        object_id = "abcdef12-3456-7890-abcd-ef1234567890"
      }
    }
  ]

  tags = {
    Environment = "Production"
  }
}

output "basic_webhook_id" {
  value = module.basic_webhook_action_group.id
}

output "secure_webhook_id" {
  value = module.secure_webhook_action_group.id
}

output "multi_webhook_id" {
  value = module.multi_webhook_action_group.id
}
```

## Webhook Payload Formats

### Common Alert Schema (recommended)
When `use_common_alert_schema = true`, alerts follow this structure:

```json
{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertId": "/subscriptions/.../alertId",
      "alertRule": "CPU usage above 80%",
      "severity": "Sev2",
      "signalType": "Metric",
      "monitorCondition": "Fired",
      "monitoringService": "Platform",
      "alertTargetIDs": ["/subscriptions/.../resourceId"],
      "originAlertId": "...",
      "firedDateTime": "2024-01-15T10:30:00Z",
      "resolvedDateTime": null,
      "description": "CPU usage exceeded threshold"
    },
    "alertContext": {
      "properties": {},
      "conditionType": "SingleResourceMultipleMetricCriteria"
    }
  }
}
```

### Legacy Schema
When `use_common_alert_schema = false`, format varies by alert type.

## Azure AD Authentication Setup

To configure Azure AD authentication for webhooks:

1. Register an application in Azure AD
2. Grant the Action Group service principal permission to your app
3. Use the application's object ID in the `aad_auth` block
4. Optionally specify `identifier_uri` and `tenant_id` for additional validation

## Webhook Endpoint Requirements

Your webhook endpoint should:
- Accept HTTP POST requests
- Respond with 2xx status code within 10 seconds
- Handle retries (Azure will retry up to 3 times)
- Validate the alert schema
- Process alerts asynchronously if handling takes time

## Security Best Practices

1. Use Azure AD authentication for production webhooks
2. Validate alert payloads in your endpoint
3. Use HTTPS endpoints only
4. Implement rate limiting on your webhook endpoint
5. Log all incoming alerts for audit purposes
6. Use separate action groups for different security zones
