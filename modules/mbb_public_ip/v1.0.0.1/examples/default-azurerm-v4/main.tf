variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "rg_location" {
  type        = string
  default     = "eastus"
  description = <<DESCRIPTION
This variable defines the Azure region where the resource group will be created.
The default value is "eastus".
DESCRIPTION
}

variable "location" {
  type        = string
  default     = "eastus"
  description = <<DESCRIPTION
This variable defines the Azure region where the resource will be created.
The default value is "eastus".
DESCRIPTION
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.rg_location
  name     = "rg-pip-v4-example"
}

# This is the module call
module "public_ip_address" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.this.name

  # MBB Naming Module Variables (Required)
  env      = "dev"
  au       = "0233985"
  owner    = "CloudOps"
  app_code = "myapp"
  bu       = "IT"
  region   = "eastus"

  # Mandatory Tags (Required)
  business_owner = "John Doe"
  budget_id      = "BUD001"
}

output "created_resource" {
  value = module.public_ip_address.public_ip_id
}
output "assigned_ip_address" {
  value = module.public_ip_address.public_ip_address
}
