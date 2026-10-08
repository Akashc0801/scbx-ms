#################################
## Resource group (separate from the Foundry landing zone)
#################################
module "resource_group" {
  source = "../../modules/scb_resource_group/v1.0.0.1"

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "rg"
  base_name            = var.jumpbox.base_name
  iterator             = var.jumpbox.iterator

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status
  product_version     = "1.0.0.1"

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags
}

#################################
## Bastion Developer (free, shared pool, no AzureBastionSubnet or public IP)
#################################
module "bastion" {
  source = "../../modules/scb_bastion_host/v1.0.0.1"

  resource_group_id  = module.resource_group.resource_id
  sku                = "Developer"
  virtual_network_id = data.azurerm_virtual_network.foundry.id

  # Naming module variables
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "bas"
  base_name            = var.jumpbox.base_name
  iterator             = var.jumpbox.iterator
  max_length           = 80 # module default is null, which the naming module rejects

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags
}

#################################
## Windows jump box in the Foundry VNet build subnet (no public IP)
#################################
module "jumpbox" {
  source = "../../modules/scb_virtual_machine/v1.0.0.0"

  resource_group_name = module.resource_group.name
  zone                = var.jumpbox.zone
  sku_size            = var.jumpbox.sku_size
  os_type             = "Windows"
  computer_name       = var.jumpbox.computer_name

  source_image_reference = var.jumpbox.image

  account_credentials = {
    admin_credentials = {
      username                           = var.jumpbox.admin_username
      generate_admin_password_or_ssh_key = true
    }
  }

  network_interfaces = {
    nic = {
      name = "nic-${local.vm_name}"
      ip_configurations = {
        ipconfig = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = data.azurerm_subnet.build.id
        }
      }
    }
  }

  # Edge policy so the Foundry portal can reach the private endpoint.
  run_commands = {
    edge_foundry_policy = {
      name     = "edge-foundry-policy"
      location = data.azurerm_virtual_network.foundry.location
      script_source = {
        script = file("${path.module}/scripts/edge-foundry-policy.ps1")
      }
    }
  }

  shutdown_schedules = {
    nightly = {
      daily_recurrence_time = var.jumpbox.shutdown_time
      timezone              = var.jumpbox.shutdown_timezone
      enabled               = true
    }
  }

  # Naming module variables (the module defaults suit storage accounts)
  org                  = local.c.org
  env                  = local.c.env
  region_code          = local.c.region_code
  location_region_code = local.c.location_region_code
  naming_format        = local.c.naming_format
  app_code             = local.c.app_code
  au                   = local.c.au
  bu                   = local.c.bu
  owner                = local.c.owner
  resource_type_code   = "vm"
  base_name            = var.jumpbox.base_name
  iterator             = var.jumpbox.iterator
  max_length           = 64
  no_dashes            = false

  # Mandatory Tags
  environment         = local.c.environment
  business_owner      = local.c.business_owner
  business_unit       = local.c.business_unit
  criticality         = local.c.criticality
  cost_center         = local.c.cost_center
  data_classification = local.c.data_classification
  compliance          = local.c.compliance
  app_name            = local.c.app_name
  app_support         = local.c.app_support
  budget_id           = local.c.budget_id
  status              = local.c.status
  service             = local.c.service

  # Optional Tags
  region              = local.c.region
  description         = local.c.description
  notification_emails = local.c.notification_emails
  additional_tags     = local.c.additional_tags
}
