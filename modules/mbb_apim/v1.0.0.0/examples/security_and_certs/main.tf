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
  managed_identities = {
    system_assigned = true
  }
  publisher_name = "Apim Example Publisher"
  security = {
    enable_backend_ssl30                           = true
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled = true
  }
  sku_name = "Premium_3"
  # sku_name = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}
