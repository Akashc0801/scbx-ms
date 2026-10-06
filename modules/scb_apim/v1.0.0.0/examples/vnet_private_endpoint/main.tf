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
  resource_group_name = "rg-apim-${random_string.name_suffix.result}"
  apim_name           = "apim-${random_string.name_suffix.result}"
  vnet_name           = "vnet-apim-${random_string.name_suffix.result}"
  private_endpoint    = "pe-apim-${random_string.name_suffix.result}"
}


# Create a virtual network for testing if needed
resource "azurerm_virtual_network" "this" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  name                = local.vnet_name
}


resource "azurerm_subnet" "default_subnet" {
  # checkov:skip=CKV2_AZURE_31: Example intentionally keeps subnet without NSG association.
  name                 = "default_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_subnet" "pe_subnet" {
  # checkov:skip=CKV2_AZURE_31: Example intentionally keeps subnet without NSG association.
  name                 = "pe_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = []
}


# Create a Private DNS Zone for API Management
resource "azurerm_private_dns_zone" "apim" {
  name                = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "apim" {
  name                  = "dnslink-azure-apim"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.apim.name
  virtual_network_id    = azurerm_virtual_network.this.id
}


# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.resource_group_name
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

  location            = azurerm_resource_group.this.location
  name                = local.apim_name
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  # private endpoints
  # Add private endpoint configuration
  private_endpoints = {
    endpoint1 = {
      name               = local.private_endpoint
      subnet_resource_id = azurerm_subnet.pe_subnet.id

      # Link to the private DNS zone we created
      private_dns_zone_resource_ids = [
        azurerm_private_dns_zone.apim.id
      ]

      tags = {
        environment = "test"
        service     = "apim"
      }
    }
  }
  publisher_name = "Apim Example Publisher"
  sku_name       = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  virtual_network_type = "None"
  zones                = ["1", "2", "3"] # For compliance with WAF
}

