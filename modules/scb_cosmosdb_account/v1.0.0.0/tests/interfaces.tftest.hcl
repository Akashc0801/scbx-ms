mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  resource_group_name = "rg-test"
  env                 = "np"
  au                  = "001"
  owner               = "platform"
  app_code            = "aiplatform"
  bu                  = "it"
  app_name            = "aiplatform"
  app_support         = "support@example.com"
  business_unit       = "it"
  business_owner      = "owner"
  environment         = "NPRD"
  base_name           = "foundry"
  iterator            = "001"
  region              = "southeastasia"
  enable_telemetry    = false

  sql_databases = {
    db = {
      name = "db"
      containers = {
        c1 = {
          name                = "c1"
          partition_key_paths = ["/id"]
        }
      }
    }
  }

  diagnostic_settings = {
    ops = {
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law"
    }
  }

  lock = {
    kind = "CanNotDelete"
  }
}

run "lock_and_diag_planned" {
  command = plan

  assert {
    condition     = length(azurerm_management_lock.this) == 1 && azurerm_management_lock.this[0].lock_level == "CanNotDelete"
    error_message = "Expected one CanNotDelete lock."
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "Expected one diagnostic setting."
  }

  assert {
    condition     = azurerm_cosmosdb_account.this.tags["ProductVersion"] == "1.0.0.0"
    error_message = "Expected ProductVersion tag 1.0.0.0."
  }
}

run "no_lock_by_default" {
  command = plan

  variables {
    lock                = null
    diagnostic_settings = {}
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 0 && length(azurerm_monitor_diagnostic_setting.this) == 0
    error_message = "Expected no lock and no diagnostic setting."
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
