mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  resource_group_name = "rg-test"
  workspace_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law-app"
  env                 = "np"
  au                  = "001"
  owner               = "platform"
  app_code            = "aiplatform"
  bu                  = "it"
  app_name            = "aiplatform"
  business_unit       = "it"
  business_owner      = "owner"
  budget_id           = "b1"
  criticality         = "Medium"
  environment         = "NPRD"
  service             = "foundry"
  base_name           = "foundry"
  iterator            = "001"
  enable_telemetry    = false

  diagnostic_settings = {
    kafka = {
      event_hub_authorization_rule_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ehns/authorizationRules/send"
      event_hub_name                           = "appinsights"
    }
  }

  lock = {
    kind = "CanNotDelete"
  }
}

run "diag_planned" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1 && azurerm_monitor_diagnostic_setting.this["kafka"].eventhub_name == "appinsights"
    error_message = "Expected one Event Hubs diagnostic setting."
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.this["kafka"].log_analytics_workspace_id == null
    error_message = "No Log Analytics destination expected for an Event Hubs-only setting."
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 1
    error_message = "Expected one lock."
  }
}

run "diag_without_destination_rejected" {
  command = plan

  variables {
    diagnostic_settings = {
      bad = {}
    }
  }

  expect_failures = [var.diagnostic_settings]
}
