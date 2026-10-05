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
  skip_provider_registration = true
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "australiaeast"
  name     = "rg-eventhub-existing-ns-example"
}

resource "azurerm_eventhub_namespace" "this" {
  #checkov:skip=CKV_AZURE_223:Example code - EH TLS not in scope
  #checkov:skip=CKV_AZURE_224:Example code - EH managed identity not in scope
  #checkov:skip=CKV_AZURE_225:Example code - EH local auth not in scope
  #checkov:skip=CKV_AZURE_226:Example code - EH public access not in scope
  #checkov:skip=CKV_AZURE_228:Example code - zone redundancy not in scope
  location            = azurerm_resource_group.this.location
  name                = "evh-existing-ns-example"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
}

locals {
  event_hubs = {
    event_hub_existing_namespace = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 2
      message_retention   = 3
      resource_group_name = module.event_hub.resource.name
    }
    # Add more event hubs if needed
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

  enable_telemetry         = false
  event_hubs               = local.event_hubs
  existing_parent_resource = { name = azurerm_eventhub_namespace.this.name }
}
