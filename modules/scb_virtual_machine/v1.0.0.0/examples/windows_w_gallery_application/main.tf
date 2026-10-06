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
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
    recovery_service {
      vm_backup_stop_protection_and_retain_data_on_destroy = false
      purge_protected_items_from_vault_on_destroy          = true
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

resource "azurerm_storage_account" "app_account" {
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
  name                     = "stvmexample"
  resource_group_name      = azurerm_resource_group.this_rg.name
}

resource "azurerm_storage_container" "app_container" {
  #checkov:skip=CKV_AZURE_34:Example code - container public access not in scope
  #checkov:skip=CKV2_AZURE_21:Example code - blob logging not in scope
  name                  = "sc-vm-example"
  container_access_type = "blob"
  storage_account_id    = azurerm_storage_account.app_account.id
}

resource "azurerm_storage_blob" "app" {
  name                   = "install-script.ps1"
  storage_account_name   = azurerm_storage_account.app_account.name
  storage_container_name = azurerm_storage_container.app_container.name
  type                   = "Block"
  source                 = "${path.module}/install-vscode.ps1"
}

#blob content = file

resource "azurerm_shared_image_gallery" "app_gallery" {
  location            = azurerm_resource_group.this_rg.location
  name                = "sig_vm_example"
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = local.tags
}

resource "azurerm_gallery_application" "app_gallery_sample" {
  gallery_id        = azurerm_shared_image_gallery.app_gallery.id
  location          = azurerm_resource_group.this_rg.location
  name              = "VSCode"
  supported_os_type = "Windows"
}

resource "azurerm_gallery_application_version" "test_app_version" {
  gallery_application_id = azurerm_gallery_application.app_gallery_sample.id
  location               = azurerm_gallery_application.app_gallery_sample.location
  name                   = "0.1.0"
  package_file           = "install-script.ps1"

  manage_action {
    install = "powershell.exe -command ./install-script.ps1"
    remove  = "powershell.exe -command ./install-script.ps1 -mode uninstall"
  }
  source {
    media_link = azurerm_storage_blob.app.id
  }
  target_region {
    name                   = azurerm_gallery_application.app_gallery_sample.location
    regional_replica_count = 1
  }
}

resource "azurerm_resource_group" "rsv_rg" {
  location = local.deployment_region
  name     = "${"rg-vm-example"}-RSV-rg"
  tags     = local.tags
}

resource "azurerm_recovery_services_vault" "test_vault" {
  #checkov:skip=CKV2_AZURE_35:Example code - managed identity not in scope
  location            = azurerm_resource_group.rsv_rg.location
  name                = "rsv-vm-example"
  resource_group_name = azurerm_resource_group.rsv_rg.name
  sku                 = "Standard"
  soft_delete_enabled = false
  storage_mode_type   = "LocallyRedundant"
}

resource "azurerm_backup_policy_vm" "test_policy" {
  name                = "${"rsv-vm-example"}-test-policy"
  recovery_vault_name = azurerm_recovery_services_vault.test_vault.name
  resource_group_name = azurerm_resource_group.rsv_rg.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 10
  }

  depends_on = [azurerm_recovery_services_vault.test_vault]
}

resource "azurerm_maintenance_configuration" "test_maintenance_config" {
  location                 = azurerm_resource_group.this_rg.location
  name                     = "${"vm-example"}-test-maint-config"
  resource_group_name      = azurerm_resource_group.this_rg.name
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  install_patches {
    reboot = "Always"

    windows {
      classifications_to_include = ["Critical", "Security", "UpdateRollup"]
    }
  }
  window {
    start_date_time = formatdate("YYYY-MM-DD hh:mm", timeadd(timestamp(), "30m"))
    time_zone       = "Pacific Standard Time"
    duration        = "04:00"
    recur_every     = "Month Second Friday"
  }

  lifecycle {
    ignore_changes = [window[0].start_date_time]
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
      role_assignments = {
        role_assignment_1 = {
          principal_id               = data.azurerm_client_config.current.client_id
          role_definition_id_or_name = "Contributor"
          description                = "Assign the Contributor role to the deployment user on this network interface resource scope."
          principal_type             = "ServicePrincipal"
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
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  data_disk_managed_disks = {
    disk1 = {
      name                 = "disk-vm-example-lun0"
      storage_account_type = "Premium_LRS"
      lun                  = 0
      caching              = "ReadWrite"
      disk_size_gb         = 32
    }
  }
  enable_telemetry           = var.enable_telemetry
  encryption_at_host_enabled = true
  gallery_applications = {
    vscode = {
      version_id = azurerm_gallery_application_version.test_app_version.id
      order      = 1
    }
  }
  maintenance_configuration_resource_ids = {
    config_1 = azurerm_maintenance_configuration.test_maintenance_config.id
  }
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  os_type               = "Windows"
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"
  sku_size              = "Standard_D2s_v5"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [
    azurerm_role_assignment.kv_admin,
    azurerm_backup_policy_vm.test_policy,
    azurerm_recovery_services_vault.test_vault
  ]
}
