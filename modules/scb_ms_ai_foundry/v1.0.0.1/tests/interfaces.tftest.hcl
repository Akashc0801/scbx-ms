mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "time" {}
mock_provider "random" {}

variables {
  env            = "np"
  au             = "001"
  owner          = "platform"
  app_code       = "aiplatform"
  bu             = "it"
  app_name       = "aiplatform"
  business_unit  = "it"
  business_owner = "owner"
  budget_id      = "b1"
  criticality    = "Medium"
  environment    = "NPRD"
  service        = "foundry"
  base_name      = "foundry"
  iterator       = "001"
  ai_foundry_accounts = {
    shared = {
      parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg"
      sku_name               = "S0"
      identity_type          = "SystemAssigned"
      disableLocalAuth       = true
      allowProjectManagement = true
      customSubDomainName    = "scb-aif-test"
      publicNetworkAccess    = "Disabled"
      diagnostic_settings = {
        ops = { workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law" }
      }
      lock = { kind = "CanNotDelete" }
    }
    nolock = {
      parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg"
      sku_name               = "S0"
      identity_type          = "SystemAssigned"
      disableLocalAuth       = true
      allowProjectManagement = true
      customSubDomainName    = "scb-aif-test2"
      publicNetworkAccess    = "Disabled"
    }
  }
}

run "lock_and_diag_planned" {
  command = plan
  assert {
    condition     = length(azurerm_management_lock.ai_foundry_account) == 1 && azurerm_management_lock.ai_foundry_account["shared"].lock_level == "CanNotDelete"
    error_message = "expected one CanNotDelete lock on 'shared' only"
  }
  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.ai_foundry_account) == 1 && contains(keys(azurerm_monitor_diagnostic_setting.ai_foundry_account), "shared.ops")
    error_message = "expected diag setting shared.ops"
  }
}

run "bad_lock_kind_rejected" {
  command = plan
  variables {
    ai_foundry_accounts = {
      a = {
        parent_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg"
        sku_name               = "S0"
        identity_type          = "SystemAssigned"
        disableLocalAuth       = true
        allowProjectManagement = true
        customSubDomainName    = "x"
        publicNetworkAccess    = "Disabled"
        lock                   = { kind = "Delete" }
      }
    }
  }
  expect_failures = [var.ai_foundry_accounts]
}

run "connection_with_secret_and_role_without_description" {
  command = plan

  variables {
    ai_foundry_projects = {
      p1 = {
        account_key   = "shared"
        sku_name      = "S0"
        identity_type = "SystemAssigned"
      }
    }
    # A connection that carries a credential makes the whole map sensitive.
    ai_foundry_project_connections = {
      appi = {
        name            = "appi"
        project_key     = "p1"
        category        = "AppInsights"
        target          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Insights/components/appi"
        auth_type       = "ApiKey"
        credentials_key = sensitive("InstrumentationKey=00000000-0000-0000-0000-000000000000")
      }
    }
    project_role_assignments = {
      r1 = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg"
        role_definition_name = "Reader"
        principal_id         = "00000000-0000-0000-0000-000000000001"
      }
    }
  }

  assert {
    condition     = length(module.project_connection.connection_ids) == 1
    error_message = "Expected one project connection."
  }
}
