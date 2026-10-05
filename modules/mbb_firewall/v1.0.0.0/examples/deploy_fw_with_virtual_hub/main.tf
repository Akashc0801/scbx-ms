terraform {
  required_version = "~> 1.5"

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
resource "azurerm_resource_group" "rg" {
  location = "malaysiawest"
  name     = "rg-fw-tst-01"
}

resource "azurerm_virtual_wan" "vwan" {
  location            = azurerm_resource_group.rg.location
  name                = "vwan-fw-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Standard"
}

resource "azurerm_virtual_hub" "vhub" {
  location            = azurerm_resource_group.rg.location
  name                = "virtual-hub"
  resource_group_name = azurerm_resource_group.rg.name
  address_prefix      = "10.1.0.0/16"
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
}

# This is the module call
module "firewall" {
  # checkov:skip=CKV_AZURE_216: Not in scope for this example - threat intel mode is managed by policy
  source = "../.."

  # Required MBB naming and tag variables
  env                = "test"
  au                 = "0000001"
  app_code           = "net"
  bu                 = "it"
  owner              = "CEAT"
  region_code        = "myw"
  resource_type_code = "afw"
  country            = "Malaysia"
  business_owner     = "Head of Cloud Engineering and Automation"
  budget_id          = "83254"

  firewall_sku_name   = "AZFW_Hub"
  firewall_sku_tier   = "Standard"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_telemetry    = var.enable_telemetry
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  firewall_virtual_hub = {
    virtual_hub_id  = azurerm_virtual_hub.vhub.id
    public_ip_count = 4
  }
  firewall_zones = ["1", "2", "3"]
}

resource "azurerm_firewall_policy" "fw_policy" {
  # checkov:skip=CKV_AZURE_220: Not in scope for this example - IDPS configuration not required for testing
  location            = azurerm_resource_group.rg.location
  name                = "fwpolicy-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
}


