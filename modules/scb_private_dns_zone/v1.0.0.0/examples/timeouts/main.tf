data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "avmrg" {
  location = "EastUS"
  name     = "rg-privdns-timeouts-example"
}

# create first sample virtual network
resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.avmrg.location
  name                = "vnet-privdns-timeouts-example"
  resource_group_name = azurerm_resource_group.avmrg.name

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }
}

# reference the module and pass in variables as needed
module "private_dns_zone" {
  # replace source with the correct link to the private_dns_zone module
  # source                = "Azure/avm-res-network-privatednszone/azurerm"
  source = "../../"

  # Mandatory Tags (Required)
  app_name        = "Private DNS Zone"
  app_support     = "support@company.com"
  business_unit   = "IT Operations"
  business_owner  = "John Doe"
  product_version = "1.0.0"
  budget_id       = "BUD001"
  criticality     = "Medium"
  environment     = "Development"
  owner           = "CloudOps"

  domain_name      = local.domain_name
  parent_id        = local.parent_id
  a_records        = local.a_records
  aaaa_records     = local.aaaa_records
  cname_records    = local.cname_records
  enable_telemetry = local.enable_telemetry
  mx_records       = local.mx_records
  ptr_records      = local.ptr_records
  soa_record       = local.soa_record
  srv_records      = local.srv_records
  tags             = local.tags
  timeouts = {
    dns_zones = {
      create = "50m"
      delete = "50m"
      read   = "10m"
      update = "50m"
    }
    vnet_links = {
      create = "50m"
      delete = "50m"
      read   = "10m"
      update = "50m"
    }
  }
  txt_records           = local.txt_records
  virtual_network_links = local.virtual_network_links
}
