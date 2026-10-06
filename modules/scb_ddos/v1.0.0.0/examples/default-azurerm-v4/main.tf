


terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.rg_location
  name     = "rg-ddos-tst"
}

# This is the module call
module "ddosprotectionplan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name

  # Required SCB naming and tag variables
  env            = "tst"
  au             = "0000001"
  app_code       = "ddos"
  bu             = "IT"
  owner          = "ITOpsTeam"
  app_name       = "ddos"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"
  service        = "ddos"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  enable_telemetry = var.enable_telemetry
}

