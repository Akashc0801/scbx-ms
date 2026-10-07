# Plans the whole stack against mocked providers with variables.tfvars:
#   terraform test -var-file=variables.tfvars
mock_provider "azurerm" {
  override_data {
    target = data.azurerm_resource_group.foundry
    values = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/scb-rg-aiplatform-np-sea-foundry-001"
      name     = "scb-rg-aiplatform-np-sea-foundry-001"
      location = "southeastasia"
    }
  }
  override_data {
    target = data.azurerm_subnet.agent
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/scb-rg-aiplatform-np-sea-foundry-001/providers/Microsoft.Network/virtualNetworks/scb-vnet-aiplatform-np-sea-foundry-001/subnets/az-snet-sbx-aiplatform-agent-nprd-001"
    }
  }
  override_data {
    target = data.azurerm_subnet.private_endpoint
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/scb-rg-aiplatform-np-sea-foundry-001/providers/Microsoft.Network/virtualNetworks/scb-vnet-aiplatform-np-sea-foundry-001/subnets/az-snet-sbx-aiplatform-foundrype-nprd-001"
    }
  }
  override_data {
    target = data.azurerm_private_dns_zone.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/scb-rg-aiplatform-np-sea-aigw-001/providers/Microsoft.Network/privateDnsZones/privatelink.example"
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

variables {
  # Blank values in variables.tfvars that the modules validate.
  common = {
    org                 = "scb"
    env                 = "np"
    region_code         = "sea"
    app_code            = "aiplatform"
    au                  = "001"
    bu                  = "it"
    owner               = "platform"
    environment         = "NPRD"
    business_owner      = "owner"
    business_unit       = "it"
    criticality         = "Medium"
    cost_center         = "cc"
    data_classification = "confidential"
    compliance          = "None"
    app_name            = "AI Platform Foundry"
    app_support         = "support@example.com"
    budget_id           = "b1"
    status              = "Live"
    service             = "foundry"
    region              = "southeastasia"
  }
}

run "full_stack_plans" {
  command = plan

  assert {
    condition     = module.key_vault.name == "scb-kv-aip-np-sea-fd-001"
    error_message = "Unexpected Key Vault name: ${module.key_vault.name}"
  }
  assert {
    condition     = module.storage_account.name == "scbstaipnpseafoundry001"
    error_message = "Unexpected storage name: ${module.storage_account.name}"
  }
  assert {
    condition     = local.expected_names.foundry == "scb-aif-aiplatform-np-sea-foundry-001"
    error_message = "Unexpected Foundry name."
  }
  assert {
    condition     = length(local.project_role_assignments) == 4 && length(local.project_connections) == 4
    error_message = "Expected 4 pre-caphost roles and 4 connections for one project."
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
