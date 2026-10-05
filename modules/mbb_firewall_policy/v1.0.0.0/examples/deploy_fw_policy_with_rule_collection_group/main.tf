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
  country            = "Malaysia"
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

module "rule_collection_group" {
  source = "../../modules/rule_collection_groups"

  # source             = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource.id
  firewall_policy_rule_collection_group_name               = "NetworkRuleCollectionGroup"
  firewall_policy_rule_collection_group_priority           = 400
  firewall_policy_rule_collection_group_application_rule_collection = [
    {
      action   = "Allow"
      name     = "ApplicationRuleCollection"
      priority = 600
      rule = [
        {
          name             = "AllowAll"
          description      = "Allow traffic to Microsoft.com"
          source_addresses = ["10.0.0.0/24"]
          protocols = [
            {
              port = 443
              type = "Https"
            }
          ]
          destination_fqdns = ["microsoft.com"]
        }
      ]
    }
  ]
  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "NetworkRuleCollection"
      priority = 400
      rule = [
        {
          name                  = "OutboundToInternet"
          description           = "Allow traffic outbound to the Internet"
          destination_addresses = ["0.0.0.0/0"]
          destination_ports     = ["443"]
          source_addresses      = ["10.0.0.0/24"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]
}
