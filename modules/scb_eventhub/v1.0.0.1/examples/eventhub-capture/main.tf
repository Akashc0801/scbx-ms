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

# Prerequisites: Storage account and container for Event Hub Capture
data "azurerm_client_config" "this" {}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_35:Example code - network rules not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version handled by provider default
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV_AZURE_206:Example code - public blob access not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft delete not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - queue CMK not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - table CMK not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - infrastructure encryption not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = "australiaeast"
  name                     = "stcaptureexample"
  resource_group_name      = "rg-example-dev"
}

resource "azurerm_storage_container" "this" {
  #checkov:skip=CKV2_AZURE_21:Example code - blob logging not in scope
  name                  = "capture"
  container_access_type = "private"
  storage_account_name  = azurerm_storage_account.this.name
}

resource "azurerm_role_assignment" "this" {
  principal_id         = data.azurerm_client_config.this.object_id
  scope                = azurerm_storage_container.this.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
}

# Example - deploys an EventHub namespace with capture enabled.
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

  # Event Hub with Capture Configuration
  event_hubs = {
    eh_capture_example = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 1
      message_retention   = 7
      resource_group_name = module.event_hub.resource.name

      capture_description = {
        enabled  = true
        encoding = "Avro"
        destination = {
          archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name = azurerm_storage_container.this.name
          storage_account_id  = azurerm_storage_account.this.id
        }
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.this
  ]
}
