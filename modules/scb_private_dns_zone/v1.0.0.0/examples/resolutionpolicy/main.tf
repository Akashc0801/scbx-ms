data "azurerm_client_config" "current" {}

# create the resource group
resource "azurerm_resource_group" "avmrg" {
  location = "EastUS"
  name     = "rg-privdns-resolution-example"
}

# create first sample virtual network
resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.avmrg.location
  name                = "vnet-privdns-resolution-example"
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

  domain_name           = local.domain_name
  parent_id             = local.parent_id
  enable_telemetry      = local.enable_telemetry
  tags                  = local.tags
  virtual_network_links = local.virtual_network_links
}

resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version handled by provider default
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  name                     = "stprivdnsresexample"
  location                 = azurerm_resource_group.avmrg.location
  resource_group_name      = azurerm_resource_group.avmrg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}
