mock_provider "random" {}
mock_provider "time" {}

variables {
  env                  = "dev"
  au                   = "001"
  owner                = "platform@example.com"
  resource_type_code   = "rg"
  product_version      = "1.0.0.1"
  app_code             = "dtx-aiplatform"
  bu                   = "platform"
  org                  = "az"
  region_code          = null
  location_region_code = "sea"
  base_name            = "aigw"
  iterator             = "001"
  environment          = "dev"
  business_owner       = "platform@example.com"
  business_unit        = "platform"
  criticality          = "Low"
  cost_center          = "001"
  data_classification  = "Internal"
  compliance           = "None"
}

run "workload_resource_group_name_and_explicit_location" {
  command = plan

  variables {
    resource_type_code = "rg"
    naming_format      = "workload"
  }

  assert {
    condition     = output.name == "az-rg-dtx-aiplatform-aigw-dev-001"
    error_message = "Workload resource group naming must match the approved component order."
  }

  assert {
    condition     = output.location == "Southeast Asia"
    error_message = "location_region_code=sea must resolve to Southeast Asia without adding sea to the name."
  }
}

run "workload_virtual_network_name_without_region" {
  command = plan

  variables {
    resource_type_code = "vnet"
    naming_format      = "workload"
  }

  assert {
    condition     = output.name == "az-vnet-dtx-aiplatform-aigw-dev-001"
    error_message = "Workload virtual network naming must omit the absent region without an empty component."
  }
}

run "workload_foundry_resource_group_name" {
  command = plan

  variables {
    resource_type_code = "rg"
    base_name          = "foundry"
    naming_format      = "workload"
  }

  assert {
    condition     = output.name == "az-rg-dtx-aiplatform-foundry-dev-001"
    error_message = "Workload foundry resource group name must match the approved component order."
  }
}

run "workload_foundry_virtual_network_name" {
  command = plan

  variables {
    resource_type_code = "vnet"
    base_name          = "foundry"
    naming_format      = "workload"
  }

  assert {
    condition     = output.name == "az-vnet-dtx-aiplatform-foundry-dev-001"
    error_message = "Workload foundry virtual network name must match the approved component order."
  }
}

run "legacy_default_name_remains_unchanged" {
  command = plan

  variables {
    resource_type_code   = "rg"
    region_code          = "sea"
    location_region_code = null
  }

  assert {
    condition     = output.name == "az-rg-dtx-aiplatform-dev-sea-aigw-001"
    error_message = "The default legacy name order must remain unchanged."
  }

  assert {
    condition     = output.location == "Southeast Asia"
    error_message = "A supplied region_code must continue to resolve the Azure location."
  }
}

run "location_requires_a_region_code" {
  command = plan

  variables {
    location_region_code = null
  }

  expect_failures = [output.location]
}

run "invalid_region_code_is_rejected" {
  command = plan

  variables {
    region_code = "invalid"
  }

  expect_failures = [var.region_code]
}

run "invalid_naming_format_is_rejected" {
  command = plan

  variables {
    naming_format = "other"
  }

  expect_failures = [var.naming_format]
}
