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

resource "azurerm_public_ip_prefix" "public_ip_prefix" {
  location            = azurerm_resource_group.rg.location
  name                = "pip-prefix-fw-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
  prefix_length       = 31
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip" {
  for_each = toset(["0", "1"])

  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "pip-fw-tst-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix.id
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  lifecycle {
    ignore_changes = [zones]
  }
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

  # Required SCB naming and tag variables
  env                = "test"
  au                 = "0000001"
  app_code           = "net"
  bu                 = "it"
  owner              = "CEAT"
  region_code        = "myw"
  resource_type_code = "afw"
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
    ipconfig1 = {
      name                 = "ipconfig1"
      subnet_id            = azurerm_subnet.subnet.id
      public_ip_address_id = azurerm_public_ip.pip[0].id
    }
    ipconfig2 = {
      name                 = "ipconfig2"
      public_ip_address_id = azurerm_public_ip.pip[1].id
    }
  }
  tags = {
    environment = "terraform"
  }
}
