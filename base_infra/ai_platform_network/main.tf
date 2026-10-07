module "resource_groups" {
  for_each = var.resource_groups

  source = "../../modules/scb_resource_group/v1.0.0.1"

  # Naming and tag variables
  env                  = each.value.env
  org                  = each.value.org
  region_code          = each.value.region_code
  location_region_code = each.value.location_region_code
  naming_format        = each.value.naming_format
  base_name            = each.value.base_name
  additional_name      = each.value.additional_name
  iterator             = each.value.iterator
  au                   = each.value.au
  app_code             = each.value.app_code
  bu                   = each.value.bu
  owner                = each.value.owner
  resource_type_code   = each.value.resource_type_code
  max_length           = each.value.max_length
  no_dashes            = each.value.no_dashes
  add_random           = each.value.add_random
  rnd_length           = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  product_name        = each.value.product_name
  product_version     = each.value.product_version
  app_support         = each.value.app_support

  # Optional Tags
  region               = each.value.region
  description          = each.value.description
  notification_emails  = each.value.notification_emails
  automation_policy    = each.value.automation_policy
  review_required      = each.value.review_required
  backup_policy        = each.value.backup_policy
  disaster_recovery    = each.value.disaster_recovery
  cost_alert_threshold = each.value.cost_alert_threshold
  budget_limit         = each.value.budget_limit

  lock             = each.value.lock
  role_assignments = each.value.role_assignments
  additional_tags  = each.value.additional_tags
}

module "network_security_groups" {
  for_each = var.network_security_groups

  source = "../../modules/scb_network_security_group/v1.0.0.1"

  depends_on = [module.resource_groups]

  # Required variables
  resource_group_name = module.resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org                  = each.value.org
  region_code          = each.value.region_code
  location_region_code = each.value.location_region_code
  naming_format        = each.value.naming_format
  base_name            = each.value.base_name
  additional_name      = each.value.additional_name
  iterator             = each.value.iterator

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # Custom rules are not defined yet; the Azure default rules apply
  security_rules = each.value.security_rules
}

module "virtual_networks" {
  for_each = var.virtual_networks

  source = "../../modules/scb_virtual_network/v1.0.0.1"

  depends_on = [module.resource_groups, module.network_security_groups]

  # Naming and tag variables
  env                  = each.value.env
  org                  = each.value.org
  region_code          = each.value.region_code
  location_region_code = each.value.location_region_code
  naming_format        = each.value.naming_format
  base_name            = each.value.base_name
  additional_name      = each.value.additional_name
  iterator             = each.value.iterator
  au                   = each.value.au
  app_code             = each.value.app_code
  bu                   = each.value.bu
  owner                = each.value.owner
  resource_type_code   = each.value.resource_type_code
  max_length           = each.value.max_length
  no_dashes            = each.value.no_dashes
  add_random           = each.value.add_random
  rnd_length           = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service
  app_support         = each.value.app_support

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # Network specific
  address_space       = each.value.address_space
  resource_group_name = module.resource_groups[each.value.resource_group_key].name
  subscription_id     = data.azurerm_client_config.current.subscription_id

  # Subnets as a map, with NSG references resolved from the NSG module keys
  subnets = {
    for subnet_key, subnet_config in each.value.subnets : subnet_key => merge(
      {
        name           = subnet_config.name
        address_prefix = subnet_config.address_prefix
      },
      subnet_config.network_security_group != null ? {
        network_security_group = {
          id = module.network_security_groups[subnet_config.network_security_group.id].resource_id
        }
      } : {}
    )
  }

  lock             = each.value.lock
  role_assignments = each.value.role_assignments
  additional_tags  = each.value.additional_tags
}

module "route_tables" {
  for_each = var.route_tables

  source = "../../modules/scb_route_tables/v1.0.0.1"

  depends_on = [module.resource_groups]

  # Required variables
  resource_group_name = module.resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org                  = each.value.org
  region_code          = each.value.region_code
  location_region_code = each.value.location_region_code
  naming_format        = each.value.naming_format
  base_name            = each.value.base_name
  additional_name      = each.value.additional_name
  iterator             = each.value.iterator

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service
  app_support         = each.value.app_support

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # Route table specific variables
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled
  routes                        = each.value.routes

  # Subnet associations resolved from the VNet module outputs
  subnet_resource_ids = {
    for assoc_key, assoc_config in each.value.subnet_associations : assoc_key =>
    module.virtual_networks[assoc_config.vnet_key].subnets[assoc_config.subnet_key].resource_id
  }

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}

module "private_dns_zones" {
  for_each = var.private_dns_zones

  source = "../../modules/scb_private_dns_zone/v1.0.0.0"

  depends_on = [module.resource_groups]

  domain_name = each.value.domain_name
  parent_id   = module.resource_groups[each.value.resource_group_key].resource_id

  # Mandatory Tags
  app_name        = each.value.app_name
  app_support     = each.value.app_support
  business_unit   = each.value.business_unit
  business_owner  = each.value.business_owner
  product_name    = each.value.product_name
  product_version = each.value.product_version
  budget_id       = each.value.budget_id
  criticality     = each.value.criticality
  environment     = each.value.environment
  owner           = each.value.owner
  status          = each.value.status

  # Links to the VNets, resolved from the VNet module outputs
  virtual_network_links = {
    for link_key, link in each.value.virtual_network_links : link_key => {
      name                 = link.name
      virtual_network_id   = module.virtual_networks[link.vnet_key].resource_id
      registration_enabled = link.registration_enabled
    }
  }

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}
