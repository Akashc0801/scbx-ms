terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-fwpolicy-tst-01"
}

# This is the module call
module "firewall_policy" {
  source = "../.."

  # Required MBB naming and tag variables
  env                = "test"
  au                 = "0000001"
  app_code           = "net"
  bu                 = "it"
  owner              = "CEAT"
  region_code        = "myw"
  resource_type_code = "afwp"
  business_owner     = "Head of Cloud Engineering and Automation"
  business_unit      = "GTD-ISD"
  app_name           = "Network Security"
  app_support        = "mss_ceat@maybank.com"
  product_name       = "firewall-policy"
  product_version    = "1.0.0.0"
  criticality        = "T1"
  environment        = "Test"
  status             = "Live"

  resource_group_name = azurerm_resource_group.this.name
  # source             = "Azure/avm-res-network-firewallpolicy/azurerm"
  enable_telemetry = var.enable_telemetry
}
