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

# Prerequisite: An existing Event Hub Namespace
resource "azurerm_eventhub_namespace" "this" {
  #checkov:skip=CKV_AZURE_223:Example code - EH TLS not in scope
  #checkov:skip=CKV_AZURE_224:Example code - EH managed identity not in scope
  #checkov:skip=CKV_AZURE_225:Example code - EH local auth not in scope
  #checkov:skip=CKV_AZURE_226:Example code - EH public access not in scope
  #checkov:skip=CKV_AZURE_228:Example code - zone redundancy not in scope
  location            = "australiaeast"
  name                = "evhns-existing-example"
  resource_group_name = "rg-example-dev"
  sku                 = "Standard"
}

# Example - deploys event hubs into an existing Event Hub Namespace.
module "event_hub" {
  #checkov:skip=CKV_AZURE_219:Example code - CMK encryption not in scope
  #checkov:skip=CKV_AZURE_224:Example code - managed identity not in scope
  source = "../../"

  # SCB Naming Module Variables (Required)
  env                = "dev"
  au                 = "0233985"
  owner              = "CloudOps"
  resource_type_code = "evhns"
  app_code           = "myapp"
  bu                 = "IT"

  # Resource Group (Required)
  resource_group_name = "rg-example-dev"

  # Mandatory Tags
  app_name            = "My EventHub Application"
  environment         = "Development"
  business_owner      = "John Doe"
  business_unit       = "IT Operations"
  criticality         = "Medium"
  cost_center         = "CC1234"
  data_classification = "Internal"
  compliance          = "None"
  budget_id           = "BUD001"
  service             = "EventHub"

  enable_telemetry = false

  # Use an existing Event Hub Namespace instead of creating a new one
  existing_parent_resource = { name = azurerm_eventhub_namespace.this.name }

  # Event Hub Configuration
  event_hubs = {
    event_hub_existing_namespace = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 2
      message_retention   = 3
      resource_group_name = module.event_hub.resource.name
    }
  }
}
