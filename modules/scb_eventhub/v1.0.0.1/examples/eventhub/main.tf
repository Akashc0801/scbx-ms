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

# Example - deploys an EventHub namespace with a single event hub.
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

  # Event Hub Configuration
  event_hubs = {
    my_event_hub = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 1
      message_retention   = 7
      resource_group_name = module.event_hub.resource.name
    }
  }
}
