terraform {
  required_version = "~> 1.5"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }

  }
}

provider "azurerm" {
  #subscription_id = "xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azapi" {
  use_cli = true
  use_msi = false
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-law-tst-01"
}

resource "azurerm_virtual_network" "this" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.this.location
  name                = "vnet-law-tst-01"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  #checkov:skip=CKV2_AZURE_31: NSG association is not required for private endpoint subnets in this example
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "snet-law-tst-01"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_private_dns_zone" "privatednszone" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatednszone_link" {
  name                  = "dnslinktovnet"
  private_dns_zone_name = azurerm_private_dns_zone.privatednszone.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# This is the module call
module "law" {
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
  resource_group_name                       = azurerm_resource_group.this.name
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
  monitor_private_link_scope = {
    pe1 = {
      name        = "law_pl_scope"
      resource_id = azurerm_resource_group.this.id
    }
  }
  monitor_private_link_scoped_service_name = "law_pl_service"
  private_endpoints = {
    pe1 = {
      subnet_resource_id          = azurerm_subnet.this.id
      network_interface_name      = "nic1"
      private_dns_zone_group_name = "dnslinktovnet"
    }
  }

}

