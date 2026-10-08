# Plans the whole stack against mocked providers with variables.tfvars:
#   terraform test -var-file=variables.tfvars
mock_provider "azurerm" {
  override_data {
    target = data.azurerm_resource_group.foundry
    values = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/az-rg-dtx-aiplatform-foundry-dev-001"
      name     = "az-rg-dtx-aiplatform-foundry-dev-001"
      location = "southeastasia"
    }
  }
  override_data {
    target = data.azurerm_subnet.agent
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/az-rg-dtx-aiplatform-foundry-dev-001/providers/Microsoft.Network/virtualNetworks/az-vnet-dtx-aiplatform-foundry-dev-001/subnets/az-snet-dtx-aiplatform-foundryagent-dev-001"
    }
  }
  override_data {
    target = data.azurerm_subnet.private_endpoint
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/az-rg-dtx-aiplatform-foundry-dev-001/providers/Microsoft.Network/virtualNetworks/az-vnet-dtx-aiplatform-foundry-dev-001/subnets/az-snet-dtx-aiplatform-foundrype-dev-001"
    }
  }
  override_data {
    target = data.azurerm_private_dns_zone.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/az-rg-dtx-aiplatform-aigw-dev-001/providers/Microsoft.Network/privateDnsZones/privatelink.example"
    }
  }
  override_data {
    target = data.azurerm_client_config.current
    values = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azapi" {
  override_data {
    target = data.azapi_resource.agent_subnet
    values = {
      output = {
        properties = {
          delegations = [{ properties = { serviceName = "Microsoft.App/environments" } }]
        }
      }
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

run "full_stack_plans" {
  command = plan

  assert {
    condition     = module.key_vault.name == "az-kv-dtx-aip-fd-dev-001"
    error_message = "Unexpected Key Vault name: ${module.key_vault.name}"
  }
  assert {
    condition     = module.storage_account.name == "azstdtxaipfoundrydev001"
    error_message = "Unexpected storage name: ${module.storage_account.name}"
  }
  assert {
    condition     = module.container_registry.name == "azacrdtxaiplatformfoundrydev001"
    error_message = "Unexpected registry name: ${module.container_registry.name}"
  }
  assert {
    condition     = local.expected_names.foundry == "az-aif-dtx-aiplatform-foundry-dev-001"
    error_message = "Unexpected Foundry name."
  }
  assert {
    condition     = module.user_assigned_identities["foundry"].resource_name == "az-id-dtx-aiplatform-foundry-dev-001"
    error_message = "Unexpected identity name: ${module.user_assigned_identities["foundry"].resource_name}"
  }
  assert {
    condition     = length(local.project_role_assignments) == 4 && length(local.project_connections) == 4
    error_message = "Expected 4 pre-caphost roles and 4 connections for one project."
  }
}

run "legacy_naming_still_matches_modules" {
  command = plan

  # The expected-name formula must follow the naming module for both formats.
  variables {
    common = {
      org                 = "az"
      env                 = "dev"
      app_code            = "dtx-aiplatform"
      naming_format       = "legacy"
      region_code         = "sea"
      au                  = "12345"
      bu                  = ""
      owner               = ""
      environment         = "DEV"
      business_owner      = ""
      business_unit       = ""
      criticality         = ""
      cost_center         = ""
      data_classification = ""
      compliance          = ""
      app_name            = "AI Platform Foundry"
      app_support         = "abc@xyz.com"
      budget_id           = ""
      status              = "Live"
      service             = "foundry"
    }
    key_vault = {
      app_code  = "dtx"
      base_name = "fd"
      iterator  = "001"
    }
    storage_account = {
      app_code  = "dtx"
      base_name = "fd"
      iterator  = "001"
    }
  }

  assert {
    condition     = module.storage_account.name == "azstdtxdevseafd001" && module.key_vault.name == "az-kv-dtx-dev-sea-fd-001" && module.ai_search.resource.name == "az-srch-dtx-aiplatform-dev-sea-foundry-001"
    error_message = "Legacy names differ from the expected-name formula."
  }
}

run "undelegated_agent_subnet_fails" {
  command = plan

  override_data {
    target = data.azapi_resource.agent_subnet
    values = {
      output = { properties = { delegations = [] } }
    }
  }

  expect_failures = [terraform_data.preflight]
}

run "too_long_foundry_name_fails" {
  command = plan

  # azapi does not check name length, so only the preflight check catches this
  # before apply.
  variables {
    foundry = {
      base_name    = "foundry-shared-platform-account-for-nonprod"
      iterator     = "001"
      identity_key = "foundry"
      projects = {
        "usecase-001" = {
          display_name = "Use case 001"
          identity_key = "usecase_001"
        }
      }
    }
  }

  expect_failures = [terraform_data.preflight]
}
