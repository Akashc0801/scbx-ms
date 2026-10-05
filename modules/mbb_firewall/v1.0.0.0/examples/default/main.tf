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

resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.rg.location
  name                = "vnet-fw-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  # checkov:skip=CKV2_AZURE_31: Not in scope for this example - AzureFirewallSubnet does not support NSG association
  address_prefixes     = ["10.1.0.0/26"]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "fw_public_ip" {
  location            = azurerm_resource_group.rg.location
  name                = "pip-fw-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    deployment = "terraform"
  }
  zones = ["1", "2", "3"]
}

resource "azurerm_firewall_policy" "fwpolicy" {
  # checkov:skip=CKV_AZURE_220: Not in scope for this example - IDPS configuration not required for testing
  location            = azurerm_resource_group.rg.location
  name                = "fwpolicy-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
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

  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = "Standard"
  location            = azurerm_resource_group.rg.location
  firewall_policy_id  = azurerm_firewall_policy.fwpolicy.id
  resource_group_name = azurerm_resource_group.rg.name
  enable_telemetry    = var.enable_telemetry
  firewall_zones      = ["1", "2", "3"]
  ip_configurations = {
    default = {
      name                 = "ipconfig1"
      subnet_id            = azurerm_subnet.subnet.id
      public_ip_address_id = azurerm_public_ip.fw_public_ip.id
    }
  }
}

