terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0"
    }
  }
}

# tflint-ignore: terraform_module_provider_declaration, terraform_output_separate, terraform_variable_separate
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  #deployment_region = "canadacentral"
  deployment_region = "canadacentral" #temporarily pinning on single region
  tags = {
    scenario = "Default"
  }
}

resource "azurerm_resource_group" "this_rg" {
  location = local.deployment_region
  name     = "rg-vm-example"
  tags     = local.tags
}

/*
# Uncomment this section if you would like to include a bastion resource with this example.
resource "azurerm_public_ip" "bastionpip" {
  name                = "pip-vm-example"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-vm-example"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name

  ip_configuration {
    name                 = "bastion-vm-example-ipconf"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}
*/

# copied over from the AzureRM example - simplifies naming for the appgw resources
locals {
  app_gw_public_ip_name          = "${azurerm_virtual_network.this.name}-pip"
  backend_address_pool_name      = "${azurerm_virtual_network.this.name}-beap"
  frontend_ip_configuration_name = "${azurerm_virtual_network.this.name}-feip"
  frontend_port_name             = "${azurerm_virtual_network.this.name}-feport"
  http_setting_name              = "${azurerm_virtual_network.this.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.this.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.this.name}-rqrt"
}

resource "azurerm_public_ip" "app_gw_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.this_rg.location
  name                = local.app_gw_public_ip_name
  resource_group_name = azurerm_resource_group.this_rg.name
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_application_gateway" "network" {
  #checkov:skip=CKV_AZURE_120:Example code - WAF not in scope
  #checkov:skip=CKV_AZURE_217:Example code - HTTPS listener not in scope
  #checkov:skip=CKV_AZURE_218:Example code - secure protocols not in scope
  location            = azurerm_resource_group.this_rg.location
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.this_rg.name
  zones               = ["1", "2", "3"]

  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    path                  = "/path1/"
    request_timeout       = 60
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gw_pip.id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.vm_subnet_2.id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.listener_name
    protocol                       = "Http"
  }
  request_routing_rule {
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 9
  }
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }
  autoscale_configuration {
    min_capacity = 2
    max_capacity = 5
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_application_security_group" "test_asg" {
  location            = azurerm_resource_group.this_rg.location
  name                = "asg-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
}

resource "azurerm_public_ip" "natgw" {
  name                = "pip-natgw-vm-example"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  name                = "natgw-vm-example"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-vm-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
}

resource "azurerm_subnet" "vm_subnet_1" {
  #checkov:skip=CKV2_AZURE_31:Example code - NSG not in scope
  name                 = "snet-vm-example-1"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_nat_gateway_association" "vm_subnet_1" {
  subnet_id      = azurerm_subnet.vm_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_subnet" "vm_subnet_2" {
  #checkov:skip=CKV2_AZURE_31:Example code - NSG not in scope
  name                 = "snet-vm-example-2"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_nat_gateway_association" "vm_subnet_2" {
  subnet_id      = azurerm_subnet.vm_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_subnet" "bastion" {
  #checkov:skip=CKV2_AZURE_31:Example code - NSG not in scope
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "lb_subnet_1" {
  #checkov:skip=CKV2_AZURE_31:Example code - NSG not in scope
  name                 = "snet-lb-example-1"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_network_security_group" "testnsg" {
  #checkov:skip=CKV_AZURE_160:Example code - HTTP access restriction not in scope
  #checkov:skip=CKV_AZURE_9:Example code - RDP access restriction not in scope
  #checkov:skip=CKV_AZURE_10:Example code - SSH access restriction not in scope
  location            = azurerm_resource_group.this_rg.location
  name                = "nsg-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name

  security_rule {
    name                       = "rule01"
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "rule02"
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Outbound"
    priority                   = 200
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_lb" "this" {
  location            = azurerm_resource_group.this_rg.location
  name                = "lb-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name

  frontend_ip_configuration {
    name      = "testFrontend"
    subnet_id = azurerm_subnet.lb_subnet_1.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool_1" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "testBackendPool"
}

resource "azurerm_lb_nat_rule" "rdp_nat_rule_1" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "rdp_nat_rule_1"
  resource_group_name            = azurerm_resource_group.this_rg.name
  frontend_ip_configuration_name = "testFrontend"
  protocol                       = "Tcp"
  frontend_port                  = 30001
  backend_port                   = 3389
}

resource "azurerm_key_vault" "this" {
  #checkov:skip=CKV_AZURE_109:Example code
  #checkov:skip=CKV_AZURE_189:Example code
  #checkov:skip=CKV2_AZURE_32:Example code - private endpoint not in scope
  name                       = "kv-vm-example"
  location                   = azurerm_resource_group.this_rg.location
  resource_group_name        = azurerm_resource_group.this_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "testvm" {
  source = "../../"

  env            = "dev"
  au             = "0233985"
  owner          = "Infrastructure Team"
  app_code       = "infra"
  bu             = "IT"
  app_name       = "Test Application"
  business_unit  = "Information Technology"
  business_owner = "John Doe"
  budget_id      = "BUD-001"
  criticality    = "High"
  environment    = "Development"
  service        = "vm"

  location = azurerm_resource_group.this_rg.location
  name     = "vm-example"
  network_interfaces = {
    network_interface_1 = {
      name = "nic-vm-example"
      application_security_groups = {
        asg_1 = {
          application_security_group_resource_id = azurerm_application_security_group.test_asg.id
        }
      }
      network_security_groups = {
        nsg_1 = {
          network_security_group_resource_id = azurerm_network_security_group.testnsg.id
        }
      }
      ip_configurations = {
        ip_configuration_1 = {
          app_gateway_backend_pools = {
            app_gw_pool_1 = {
              app_gateway_backend_pool_resource_id = [for value in azurerm_application_gateway.network.backend_address_pool : value.id if value.name == local.backend_address_pool_name][0]
            }
          }
          load_balancer_backend_pools = {
            lb_pool_1 = {
              load_balancer_backend_pool_resource_id = azurerm_lb_backend_address_pool.pool_1.id
            }
          }
          load_balancer_nat_rules = {
            lb_nat_rule_1 = {
              load_balancer_nat_rule_resource_id = azurerm_lb_nat_rule.rdp_nat_rule_1.id
            }
          }
          name                          = "nic-vm-example-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.vm_subnet_1.id
        }
      }
    }
  }
  resource_group_name = azurerm_resource_group.this_rg.name
  zone                = 1
  account_credentials = {
    key_vault_configuration = {
      resource_id = azurerm_key_vault.this.id
    }
  }
  enable_telemetry           = var.enable_telemetry
  encryption_at_host_enabled = true
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  os_type  = "Windows"
  sku_size = "Standard_D2s_v5"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [azurerm_role_assignment.kv_admin, azurerm_network_security_group.testnsg, azurerm_lb.this, azurerm_application_security_group.test_asg, azurerm_application_gateway.network] #setting explicit dependencies to enforce destroy ordering
}
