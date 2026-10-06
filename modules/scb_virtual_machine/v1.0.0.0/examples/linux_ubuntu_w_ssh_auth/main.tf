terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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

resource "azurerm_resource_group" "this_rg_secondary" {
  location = local.deployment_region
  name     = "${"rg-vm-example"}-alt"
  tags     = local.tags
}

/* #uncomment these resources to enable bastion
resource "azurerm_public_ip" "bastionpip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.this_rg.location
  name                = "pip-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  location            = azurerm_resource_group.this_rg.location
  name                = "bastion-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name

  ip_configuration {
    name                 = "bastion-vm-example-ipconf"
    public_ip_address_id = azurerm_public_ip.bastionpip.id
    subnet_id            = azurerm_subnet.bastion.id
  }
}
*/

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "example_identity" {
  location            = azurerm_resource_group.this_rg.location
  name                = "uami-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = local.tags
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "admin_ssh_key" {
  #checkov:skip=CKV_AZURE_41:Example code - secret expiration not in scope
  #checkov:skip=CKV_AZURE_114:Example code - secret content_type not in scope
  key_vault_id = azurerm_key_vault.this.id
  name         = "azureuser-ssh-private-key"
  value        = tls_private_key.this.private_key_pem

  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}

resource "tls_private_key" "this_2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "admin_ssh_key_2" {
  #checkov:skip=CKV_AZURE_41:Example code - secret expiration not in scope
  #checkov:skip=CKV_AZURE_114:Example code - secret content_type not in scope
  key_vault_id = azurerm_key_vault.this.id
  name         = "azureuser-ssh-private-key-2"
  value        = tls_private_key.this_2.private_key_pem

  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}

resource "azurerm_disk_encryption_set" "this" {
  location            = azurerm_resource_group.this_rg.location
  name                = "des-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
  key_vault_key_id    = azurerm_key_vault_key.des_key.id
  tags                = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
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

resource "azurerm_key_vault_key" "des_key" {
  #checkov:skip=CKV_AZURE_112:Example code
  #checkov:skip=CKV_AZURE_40:Example code
  name         = "des-key"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 4096
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.kv_admin]
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
      name                           = "nic-vm-example-1"
      accelerated_networking_enabled = true
      ip_forwarding_enabled          = true
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "nic-vm-example-nic1-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.vm_subnet_1.id
        }
      }
      resource_group_name = azurerm_resource_group.this_rg_secondary.name
    }
    network_interface_2 = {
      name                  = "nic-vm-example-2"
      ip_forwarding_enabled = true
      ip_configurations = {
        ip_configuration_avs_facing = {
          name                          = "nic-vm-example-nic2-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.vm_subnet_2.id
        }
      }
      is_primary = true
    }
  }
  resource_group_name = azurerm_resource_group.this_rg.name
  zone                = 1
  account_credentials = {
    admin_credentials = {
      username                           = "azureuser"
      ssh_keys                           = [tls_private_key.this.public_key_openssh, tls_private_key.this_2.public_key_openssh]
      generate_admin_password_or_ssh_key = false
    }
  }
  data_disk_managed_disks = {
    disk1 = {
      name                   = "disk-vm-example-lun0"
      storage_account_type   = "Premium_LRS"
      lun                    = 0
      caching                = "ReadWrite"
      disk_size_gb           = 32
      disk_encryption_set_id = azurerm_disk_encryption_set.this.id
      resource_group_name    = azurerm_resource_group.this_rg_secondary.name
      role_assignments = {
        role_assignment_2 = {
          principal_id               = data.azurerm_client_config.current.client_id
          role_definition_id_or_name = "Contributor"
          description                = "Assign the Contributor role to the deployment user on this managed disk resource scope."
          principal_type             = "ServicePrincipal"
        }
      }
    }
  }
  enable_telemetry           = var.enable_telemetry
  encryption_at_host_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
  os_disk = {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.this.id
  }
  os_type = "Linux"
  role_assignments = {
    role_assignment_2 = {
      principal_id               = data.azurerm_client_config.current.client_id
      role_definition_id_or_name = "Virtual Machine Contributor"
      description                = "Assign the Virtual Machine Contributor role to the deployment user on this virtual machine resource scope."
      principal_type             = "ServicePrincipal"
    }
  }
  role_assignments_system_managed_identity = {
    role_assignment_1 = {
      scope_resource_id          = azurerm_key_vault.this.id
      role_definition_id_or_name = "Key Vault Secrets Officer"
      description                = "Assign the Key Vault Secrets Officer role to the virtual machine's system managed identity"
      principal_type             = "ServicePrincipal"
    }
  }
  sku_size = "Standard_D2s_v5"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}
