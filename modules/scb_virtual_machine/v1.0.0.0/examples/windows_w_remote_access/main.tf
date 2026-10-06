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
  admin_username    = "azureuser"
  deployment_region = "canadacentral" #temporarily pinning on single region
  inline_remote_exec = [
    "schtasks /Create /TN \"\\AVM\\RotateWinRMListenerThumbprint\" /SC MINUTE /MO 1 /TR \"\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -ExecutionPolicy Bypass -Command & { . 'C:\\AzureData\\w_sc_task_rotate_winrms_cert.ps1'; Update-WinRMCertificate -CommonName 'CN=${"vm-example"}' -WinRmsPort ${local.winrms_port} }\" /RU \"SYSTEM\" /RL HIGHEST /F"
  ]
  os_type = "Windows"
  tags = {
    scenario = "basic_windows_w_winrms"
  }
  winrms_port = 15986
}

resource "azurerm_resource_group" "this_rg" {
  location = local.deployment_region
  name     = "rg-vm-example"
  tags     = local.tags
}

resource "azurerm_network_security_group" "remote" {
  #checkov:skip=CKV_AZURE_10:Example code - SSH restriction not in scope
  location            = azurerm_resource_group.this_rg.location
  name                = "nsg-remote"
  resource_group_name = azurerm_resource_group.this_rg.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = local.winrms_port
    direction                  = "Inbound"
    name                       = "WinRMs"
    priority                   = 151
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "SSH"
    priority                   = 152
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

/* Uncomment this section if you would like to include a bastion resource with this example.
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

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this_rg.location
  name                = "uami-vm-example"
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = local.tags
}

resource "random_string" "public_ip_fqdn" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_public_ip" "this" {
  allocation_method       = "Static"
  location                = azurerm_resource_group.this_rg.location
  name                    = "pip-vm-example"
  resource_group_name     = azurerm_resource_group.this_rg.name
  domain_name_label       = random_string.public_ip_fqdn.result
  idle_timeout_in_minutes = 30
  ip_version              = "IPv4"
  sku                     = "Standard"
  sku_tier                = "Regional"
  zones                   = ["1", "2", "3"]
}

# For production deployment, use a different keyvault for the winrm certificate from the password
resource "azurerm_key_vault_certificate" "self_signed_winrm" {
  key_vault_id = azurerm_key_vault.this.id
  name         = try(format("%s-winrms-cert", "vm-example"))
  tags         = local.tags

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_type   = "RSA"
      reuse_key  = true
      key_size   = 4096
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
    x509_certificate_properties {
      key_usage = [
        "digitalSignature",
        "keyAgreement",
        "keyEncipherment",
      ]
      subject            = format("CN=%s", "vm-example")
      validity_in_months = 12
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      subject_alternative_names {
        dns_names = flatten([
          # format("%s.%s", coalesce(var.computer_name, var.name), nic.internal_domain_name_suffix)
          "vm-example",
          azurerm_public_ip.this.ip_address,
          azurerm_public_ip.this.fqdn
        ])
      }
    }
  }

  depends_on = [azurerm_role_assignment.kv_admin]
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
          public_ip_address_resource_id = azurerm_public_ip.this.id
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
  # custom_data got injected in the vm at c:\AzureData\CustomData.bin
  custom_data = base64encode(<<-CD
  # Enable WinRM HTTPS listener
  Enable-PSRemoting -Force

  Get-ChildItem wsman:\localhost\Listener\ | Where-Object -Property Keys -like 'Transport=HTTP*' | Remove-Item -Recurse
  $certificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "CN=${"vm-example"}"}
  New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -Port ${local.winrms_port} -CertificateThumbprint $certificate.thumbprint -Force

  # Allow HTTPS traffic in the Windows firewall
  New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort ${local.winrms_port} -Protocol TCP -Action Allow -Verbose

  # Set HTTPS listener to be the default listener
  winrm set winrm/config/service/Auth '@{Certificate="true"}'
  winrm set winrm/config/service '@{AllowUnencrypted="false"}'

  # Restart WinRM service
  Restart-Service WinRM -Force
  # Display for logs
  WinRM e winrm/config/listener
  CD
  )
  enable_telemetry = var.enable_telemetry
  extensions = {
    install_winrms = {
      name                        = "install_winrms"
      failure_suppression_enabled = false
      publisher                   = "Microsoft.Compute"
      type                        = "CustomScriptExtension"
      type_handler_version        = "1.10"

      settings = jsonencode(
        {
          commandToExecute = "copy c:\\AzureData\\CustomData.bin c:\\AzureData\\winrms.ps1 && powershell.exe -ExecutionPolicy Unrestricted -File c:\\AzureData\\winrms.ps1 > C:\\AzureData\\winrms.log"
        }
      )

    }
    openssh_windows = {
      name                        = "WindowsOpenSSH"
      failure_suppression_enabled = true
      publisher                   = "Microsoft.Azure.OpenSSH"
      type                        = "WindowsOpenSSH"
      type_handler_version        = "3.0"
    }
    keyvault_extension = {
      name                       = "KVVMExtension"
      publisher                  = "Microsoft.Azure.KeyVault"
      type                       = lower(local.os_type) == "windows" ? "KeyVaultForWindows" : "KeyVaultForLinux"
      type_handler_version       = lower(local.os_type) == "windows" ? "3.0" : "2.0"
      auto_upgrade_minor_version = true
      settings = jsonencode(
        {
          secretsManagementSettings = {
            pollingIntervalInS = "60"                                              #"3600"
            linkOnRenewal      = lower(local.os_type) == "windows" ? false : false # always false on Linux.
            requireInitialSync = true                                              # requires user msi https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-linux#extension-dependency-ordering
            observedCertificates = [
              {
                url                      = azurerm_key_vault_certificate.self_signed_winrm.versionless_secret_id
                certificateStoreName     = lower(local.os_type) == "windows" ? "MY" : null
                certificateStoreLocation = lower(local.os_type) == "windows" ? "LocalMachine" : "/var/lib/waagent/Microsoft.Azure.KeyVault"
              }
            ]
          }
          authenticationSettings = {
            msiEndpoint = "http://169.254.169.254/metadata/identity/oauth2/token"
            msiClientId = azurerm_user_assigned_identity.this.client_id
          }
        }
      )
      # Troubleshooting logs - https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-windows?tabs=version3#review-logs-and-configuration
      # more
    }
  }
  managed_identities = {
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id]
  }
  os_type = local.os_type
  # Install the certiciate for WinRMs in the computer certificate store
  secrets = [
    {
      key_vault_id = azurerm_key_vault.this.id
      certificate = [
        {
          url   = azurerm_key_vault_certificate.self_signed_winrm.secret_id
          store = "My"
        }
      ]
    }
  ]
  sku_size = "Standard_D2s_v5"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  tags = local.tags
  winrm_listeners = [
    {
      protocol        = "Https"
      certificate_url = azurerm_key_vault_certificate.self_signed_winrm.secret_id
    },
    # {
    #   protocol = "Http"
    # }
  ]

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "terraform_data" "enable_certificate_rotation_on_winrms_listener" {
  triggers_replace = sha512(jsonencode([
    azurerm_key_vault_certificate.self_signed_winrm.versionless_secret_id,
    local.admin_username,
    local.inline_remote_exec,
    local.winrms_port,
    module.testvm.virtual_machine_azurerm.virtual_machine_id,
    sensitive(module.testvm.admin_password)
  ]))

  connection {
    host     = azurerm_public_ip.this.ip_address
    https    = true
    insecure = true # Using a self-signed certificate
    password = module.testvm.admin_password
    port     = local.winrms_port
    type     = "winrm"
    user     = local.admin_username
    use_ntlm = true
  }

  provisioner "file" {
    source      = "w_sc_task_rotate_winrms_cert.ps1"
    destination = "C:\\AzureData\\w_sc_task_rotate_winrms_cert.ps1"
  }

  provisioner "remote-exec" {
    inline = local.inline_remote_exec
  }

  depends_on = [module.testvm]
}

resource "terraform_data" "test_connection_ssh" {
  triggers_replace = sha512(jsonencode([
    azurerm_key_vault_certificate.self_signed_winrm.versionless_secret_id,
    local.admin_username,
    local.winrms_port,
    module.testvm.admin_password,
    module.testvm.virtual_machine_azurerm.virtual_machine_id
  ]))

  connection {
    agent           = false # for windows
    host            = azurerm_public_ip.this.ip_address
    password        = module.testvm.admin_password
    port            = 22
    target_platform = "windows"
    type            = "ssh"
    user            = local.admin_username
  }

  provisioner "remote-exec" {
    inline = [
      "ipconfig /all"
    ]
  }

  depends_on = [module.testvm]
}
