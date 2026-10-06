terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }

  }
}

provider "azurerm" {
  features {}
  #subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

# This is required for resource modules
resource "azurerm_resource_group" "rg" {
  location = "malaysiawest"
  name     = "rg-law-tst-01"
}

# This is the module call
module "log_analytics_workspace" {
  source = "../../"
  # source             = "Azure/avm-res-operationalinsights-workspace/azurerm"

  # Required SCB naming and tag variables
  env                = "test"
  au                 = "0000001"
  app_code           = "net"
  bu                 = "it"
  owner              = "CEAT"
  region_code        = "myw"
  resource_type_code = "law"
  business_unit      = "GTD-ISD"
  business_owner     = "Head of Cloud Engineering and Automation"
  app_name           = "Log Analytics Workspace"
  budget_id          = "83254"
  criticality        = "T1"
  environment        = "Test"

  enable_telemetry                          = var.enable_telemetry
  resource_group_name                       = azurerm_resource_group.rg.name
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
}

module "log_analytics_solution" {
  source                                       = "../../modules/log_analytics_solution"
  log_analytics_solution_solution_name         = "SecurityInsights"
  log_analytics_solution_workspace_name        = module.log_analytics_workspace.resource.name
  log_analytics_solution_workspace_resource_id = module.log_analytics_workspace.resource_id
  log_analytics_solution_resource_group_name   = azurerm_resource_group.rg.name
  log_analytics_solution_location              = azurerm_resource_group.rg.location
  log_analytics_solution_plan = {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}
