terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}

provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
}

# Generate deterministic short suffix for example resource names.
resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  resource_group_name        = "rg-apim-${random_string.name_suffix.result}"
  apim_name                  = "apim-${random_string.name_suffix.result}"
  diag_workspace_name        = "diag-law-${random_string.name_suffix.result}"
  diag_workspace_name_second = "diag2-law-${random_string.name_suffix.result}"
  diag_setting_name          = "aml-${random_string.name_suffix.result}"
  diag_setting_name_second   = "aml2-${random_string.name_suffix.result}"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.resource_group_name
}

resource "azurerm_log_analytics_workspace" "diag" {
  location            = azurerm_resource_group.this.location
  name                = local.diag_workspace_name
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_log_analytics_workspace" "diag2" {
  location            = azurerm_resource_group.this.location
  name                = local.diag_workspace_name_second
  resource_group_name = azurerm_resource_group.this.name
}
# This is the module call
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  #checkov:skip=CKV_AZURE_174: Public access can be intentionally enabled via module input for supported deployment scenarios.

  # Required naming and tagging inputs from main module
  env            = "prod"
  au             = "00121"
  owner          = "CEAT"
  app_code       = "mgmt"
  bu             = "it"
  app_name       = "API Management Platform"
  business_unit  = "GTD-ISD"
  business_owner = "Head of Cloud Engineering and Automation"
  budget_id      = "83254"
  criticality    = "T1"
  environment    = "Prod"
  service        = "apim"

  location            = var.location
  name                = local.apim_name
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  diagnostic_settings = {
    diag = {
      name                  = local.diag_setting_name
      workspace_resource_id = azurerm_log_analytics_workspace.diag.id
    },
    diag2 = {
      name                  = local.diag_setting_name_second
      workspace_resource_id = azurerm_log_analytics_workspace.diag2.id
      log_categories = [
        "GatewayLogs",             # Logs related to ApiManagement Gateway
        "WebSocketConnectionLogs", # Logs related to Websocket Connections
        "DeveloperPortalAuditLogs" # Logs related to Developer Portal usage
      ]
    }
  }
  enable_telemetry = var.enable_telemetry
  publisher_name   = "John Wick"
  sku_name         = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}

