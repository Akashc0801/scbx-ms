terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
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
    scenario = "Run Command"
  }
}

resource "azurerm_resource_group" "this_rg" {
  location = local.deployment_region
  name     = "rg-vm-example"
  tags     = local.tags
}

/*
#uncomment this block to enable bastion host
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

resource "random_string" "name_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this_rg.location
  name                     = "avmstorage${random_string.name_suffix.result}"
  resource_group_name      = azurerm_resource_group.this_rg.name
}

resource "azurerm_storage_container" "this" {
  #checkov:skip=CKV_AZURE_34:Example code - container public access not in scope
  #checkov:skip=CKV2_AZURE_21:Example code - blob logging not in scope
  name                  = "example-sc"
  container_access_type = "blob"
  storage_account_id    = azurerm_storage_account.this.id
}

resource "azurerm_storage_blob" "example1" {
  name                   = "script1"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source_content         = "echo hello world"
}

resource "azurerm_storage_blob" "example2" {
  name                   = "output"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Append"
}

resource "azurerm_storage_blob" "example3" {
  name                   = "error"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Append"
}

resource "azurerm_role_assignment" "this" {
  principal_id         = azurerm_user_assigned_identity.example_identity.principal_id
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_user_assigned_identity" "example_identity" {
  location            = azurerm_resource_group.this_rg.location
  name                = "uami-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = local.tags
}

resource "random_password" "admin_password" {
  length           = 22
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  special          = true
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
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "nic-vm-example-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.vm_subnet_1.id
        }
      }
    }
  }
  resource_group_name = azurerm_resource_group.this_rg.name
  zone                = 1
  account_credentials = {
    admin_credentials = {
      password                           = random_password.admin_password.result
      generate_admin_password_or_ssh_key = false
    }
  }
  additional_unattend_contents = [
    {
      setting = "FirstLogonCommands"
      content = "<FirstLogonCommands><SynchronousCommand><CommandLine>%windir%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoProfile -ExecutionPolicy Bypass -file C:\\test.ps1</CommandLine><Description>script</Description><Order>2</Order></SynchronousCommand></FirstLogonCommands>"
    }
  ]
  enable_telemetry           = var.enable_telemetry
  encryption_at_host_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  os_type = "Windows"
  run_commands = {
    test_example_simple = {
      location = azurerm_resource_group.this_rg.location
      name     = "example-command"
      script_source = {
        script = "echo %param1%"
      }
      parameters = {
        param1 = {
          name  = "param1"
          value = "value1"
        }
      }

      tags = local.tags
    }

    test_example_from_storage = {
      location        = azurerm_resource_group.this_rg.location
      name            = "example-command-storage"
      error_blob_uri  = azurerm_storage_blob.example3.url
      output_blob_uri = azurerm_storage_blob.example2.url
      script_source = {
        script_uri = azurerm_storage_blob.example1.url
      }

      error_blob_managed_identity = {
        client_id = azurerm_user_assigned_identity.example_identity.client_id
      }

      output_blob_managed_identity = {
        client_id = azurerm_user_assigned_identity.example_identity.client_id
      }

      tags = local.tags
    }
  }
  run_commands_secrets = {
    test_example_from_storage = {
      run_as_password = random_password.admin_password.result
      run_as_user     = "azureuser"
    }
  }
  sku_size = "Standard_D2s_v5"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [azurerm_role_assignment.kv_admin, azurerm_user_assigned_identity.example_identity, azurerm_role_assignment.this]
}
