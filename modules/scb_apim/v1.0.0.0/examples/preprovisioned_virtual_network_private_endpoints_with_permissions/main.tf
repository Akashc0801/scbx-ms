# The identities are not needs to deploy into a vent, but are showcasing how to mix and use
# the different features of the AVM
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
  uai_name            = "uai-apim-${random_string.name_suffix.result}"
  private_endpoint    = "pe-apim-${random_string.name_suffix.result}"
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.resource_group_name
}



# Create Virtual Network and Subnets
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
    cost_center = "test"
  }
}


resource "azurerm_subnet" "private_endpoints" {
  # checkov:skip=CKV2_AZURE_31: Example intentionally keeps subnet without NSG association.
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "private_endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "apim_subnet" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "apim_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}


resource "azurerm_subnet" "default" {
  # checkov:skip=CKV2_AZURE_31: Example intentionally keeps subnet without NSG association.
  address_prefixes     = ["10.0.3.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# Private DNS Zone for API Management
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

resource "azurerm_user_assigned_identity" "cmk" {
  location            = azurerm_resource_group.this.location
  name                = local.uai_name
  resource_group_name = azurerm_resource_group.this.name
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

  # Remove the hardcoded location and use the resource group location
  location            = azurerm_resource_group.this.location
  name                = local.apim_name
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  # Add private endpoint configuration
  private_endpoints = {
    endpoint1 = {
      name               = local.private_endpoint
      subnet_resource_id = azurerm_subnet.private_endpoints.id

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
  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }

    cosmos_db = {
      role_definition_id_or_name       = "Key Vault Crypto Service Encryption User"
      principal_id                     = "a232010e-820c-4083-83bb-3ace5fc29d0b"
      skip_service_principal_aad_check = true # because it isn't a traditional SP
    }

    uai = {
      role_definition_id_or_name = "Key Vault Crypto Officer" # Key Vault Crypto Officer
      principal_id               = azurerm_user_assigned_identity.cmk.principal_id
    }
  }
  sku_name = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}
