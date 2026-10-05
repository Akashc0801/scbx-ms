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
resource "azurerm_resource_group" "rg" {
  location = "malaysiawest"
  name     = "rg-fwpolicy-tst-01"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "vnet-fwpolicy-tst-01"
}

resource "azurerm_subnet" "subnet" {
  # checkov:skip=CKV2_AZURE_31: Not in scope for this example - AzureFirewallSubnet does not support NSG association
  address_prefixes     = ["10.1.0.0/26"]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "pip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_ip_group" "ipgroup_1" {
  location            = azurerm_resource_group.rg.location
  name                = "ipgroup1"
  resource_group_name = azurerm_resource_group.rg.name
  cidrs               = ["192.168.0.1", "172.16.240.0/20", "10.48.0.0/12"]
}

resource "azurerm_ip_group" "ipgroup_2" {
  location            = azurerm_resource_group.rg.location
  name                = "ipgroup2"
  resource_group_name = azurerm_resource_group.rg.name
  cidrs               = ["10.100.10.0/24", "192.100.10.4", "10.150.20.20"]
}

resource "azurerm_firewall" "firewall" {
  # checkov:skip=CKV_AZURE_216: Not in scope for this example - threat intel mode is managed by policy
  location            = azurerm_resource_group.rg.location
  name                = "fw-tst-01"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = module.firewall_policy.resource.id
  zones               = ["1", "2", "3"]
  ip_configuration {
    name                 = "ipconfig1"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

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

  resource_group_name = azurerm_resource_group.rg.name
  enable_telemetry    = var.enable_telemetry
}

module "rule_collection_group" {
  source = "../../modules/rule_collection_groups"

  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource.id
  firewall_policy_rule_collection_group_name               = "IPGroupRCG"
  firewall_policy_rule_collection_group_priority           = 400
  firewall_policy_rule_collection_group_application_rule_collection = [
    {
      action   = "Allow"
      name     = "ApplicationRuleCollection"
      priority = 201
      rule = [
        {
          name              = "AllowMicrosoft"
          destination_fqdns = ["*.microsoft.com"]
          source_ip_groups  = [azurerm_ip_group.ipgroup_2.id]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
        }
      ]
    }
  ]
  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "NetworkRuleCollection"
      priority = 101
      rule = [
        {
          name                  = "OutboundToIPGroups"
          destination_ports     = ["443"]
          destination_ip_groups = [azurerm_ip_group.ipgroup_1.id]
          source_ip_groups      = [azurerm_ip_group.ipgroup_2.id]
          protocols             = ["TCP"]
        }
      ]
    }
  ]
}
