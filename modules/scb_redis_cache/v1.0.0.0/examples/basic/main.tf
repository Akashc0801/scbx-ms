terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  tags = {
    scenario = "default"
  }
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "rg-redis-basic-example"
}


# This is the module call
module "basic" {
  #checkov:skip=CKV_AZURE_89:Example code - public network access not in scope
  #checkov:skip=CKV_AZURE_230:Example code - standard replication not in scope for Basic SKU
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = "redis-basic-example"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  sku_name            = "Basic"
  tags                = local.tags
  zones               = null
}
