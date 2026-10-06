data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "terraform_state" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "shared"
    workload    = "terraform-state"
    managed-by  = "terraform"
  }
}

resource "azurerm_storage_account" "terraform_state" {
  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.terraform_state.name
  location                          = azurerm_resource_group.terraform_state.location
  account_tier                      = "Standard"
  account_replication_type          = "ZRS"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  public_network_access_enabled     = true
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = {
    environment = "shared"
    workload    = "terraform-state"
    managed-by  = "terraform"
  }
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "terraform_state_owner" {
  scope                = azurerm_storage_account.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
