terraform {
  required_version = ">= 1.3.0"

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
  location = "australiaeast"
  name     = "rg-eventhub-example"
}

locals {
  event_hubs = {
    my_event_hub = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 1
      message_retention   = 7
      resource_group_name = module.event_hub.resource.name
    }
  }
}

module "event_hub" {
  #checkov:skip=CKV_AZURE_219:Example code - CMK encryption not in scope
  #checkov:skip=CKV_AZURE_224:Example code - managed identity not in scope
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name

  # MBB Naming Module Variables (Required)
  env      = "dev"
  au       = "0233985"
  owner    = "CloudOps"
  app_code = "myapp"
  bu       = "IT"

  # Mandatory Tags (Required)
  app_name       = "Event Hub"
  business_unit  = "IT Operations"
  business_owner = "John Doe"
  budget_id      = "BUD001"
  criticality    = "Medium"
  environment    = "Development"
  service        = "EventHub"

  enable_telemetry = var.enable_telemetry
  event_hubs       = local.event_hubs
}
