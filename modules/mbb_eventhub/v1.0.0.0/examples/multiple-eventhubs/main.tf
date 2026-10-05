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
  name     = "rg-eventhub-multiple-example"
}

# Get the current client details of the principal running terraform, used to apply RBAC permissions
data "azurerm_client_config" "this" {}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_35:Example code - network rules not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version handled by provider default
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft delete not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - queue CMK not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - table CMK not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - infrastructure encryption not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = "stevhmultiple01"
  resource_group_name      = azurerm_resource_group.this.name
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

locals {
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

      role_assignments = {
        eh_sender_role = {
          role_definition_id_or_name = "Azure Event Hubs Data sender"
          principal_id               = data.azurerm_client_config.this.object_id
        }
      }
    },
    eh_another_hub = {
      namespace_name      = module.event_hub.resource.id
      partition_count     = 2
      message_retention   = 3
      resource_group_name = module.event_hub.resource.name

      role_assignments = {
        eh_receiver_role = {
          role_definition_id_or_name = "Azure Event Hubs Data receiver"
          principal_id               = data.azurerm_client_config.this.object_id
        }
      }

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

  depends_on = [
    azurerm_role_assignment.this
  ]
}
