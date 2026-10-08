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
      } : {},
      subnet_config.delegations != null ? {
        delegations = subnet_config.delegations
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

  depends_on = [
    module.resource_groups,
    module.firewalls,
    azurerm_virtual_network_peering.aigw_to_foundry,
    azurerm_virtual_network_peering.foundry_to_aigw,
  ]

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
  routes = {
    for route_key, route in each.value.routes : route_key => merge(
      route,
      route.firewall_key != null ? {
        next_hop_in_ip_address = module.firewalls[route.firewall_key].resource.ip_configuration[0].private_ip_address
      } : {}
    )
  }

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


module "public_ips" {
  for_each = var.public_ips

  source = "../../modules/scb_public_ip/v1.0.0.1"

  depends_on = [module.resource_groups]

  resource_group_name = module.resource_groups[each.value.resource_group_key].name

  # Naming module variables
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

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  app_support         = each.value.app_support
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails

  # Public IP specific
  allocation_method = each.value.allocation_method
  sku               = each.value.sku
  sku_tier          = each.value.sku_tier
  zones             = each.value.zones

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}

module "firewall_policies" {
  for_each = var.firewall_policies

  source = "../../modules/scb_firewall_policy/v1.0.0.1"

  depends_on = [module.resource_groups]

  resource_group_name = module.resource_groups[each.value.resource_group_key].name

  # Naming module variables
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

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  app_support         = each.value.app_support
  product_name        = each.value.product_name
  product_version     = each.value.product_version
  budget_id           = each.value.budget_id
  status              = each.value.status

  # Optional Tags. The module merges these into tags when not null, so blanks are explicit.
  service             = each.value.service
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails
  delete_after        = ""
  tier                = ""
  app_id              = ""
  auto_delete         = ""
  auto_shutdown       = ""
  disaster_recovery   = ""
  integration_id      = ""
  experiment_phase    = ""
  os                  = ""
  last_vm_accessed    = ""
  retention           = ""

  # Firewall policy specific
  firewall_policy_sku                      = each.value.sku
  firewall_policy_threat_intelligence_mode = each.value.threat_intelligence_mode
  firewall_policy_dns = {
    proxy_enabled = each.value.dns_proxy_enabled
    servers       = each.value.dns_servers
  }

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}

module "firewalls" {
  for_each = var.firewalls

  source = "../../modules/scb_firewall/v1.0.0.1"

  depends_on = [module.resource_groups, module.virtual_networks]

  resource_group_name = module.resource_groups[each.value.resource_group_key].name

  # Naming module variables
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

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  app_support         = each.value.app_support
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails

  # Firewall specific
  firewall_sku_name  = each.value.firewall_sku_name
  firewall_sku_tier  = each.value.firewall_sku_tier
  firewall_zones     = each.value.firewall_zones
  firewall_policy_id = module.firewall_policies[each.value.firewall_policy_key].resource_id

  # Public IPs and the AzureFirewallSubnet resolved from module outputs
  ip_configurations = {
    for ip_key, ip_config in each.value.ip_configurations : ip_key => {
      name                 = ip_config.name
      public_ip_address_id = module.public_ips[ip_config.public_ip_key].resource_id
      subnet_id = (
        ip_config.vnet_key != null && ip_config.subnet_key != null
        ? module.virtual_networks[ip_config.vnet_key].subnets[ip_config.subnet_key].resource_id
        : null
      )
    }
  }

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}

module "private_dns_resolvers" {
  for_each = var.private_dns_resolvers

  source = "../../modules/scb_dnsresolver/v1.0.0.0"

  depends_on = [module.resource_groups, module.virtual_networks]

  name                        = each.value.name
  resource_group_name         = module.resource_groups[each.value.resource_group_key].name
  location                    = module.resource_groups[each.value.resource_group_key].resource.location
  virtual_network_resource_id = module.virtual_networks[each.value.vnet_key].resource_id

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

  # Subnet names resolved from the VNet module outputs
  inbound_endpoints = {
    for key, endpoint in each.value.inbound_endpoints : key => {
      name                         = endpoint.name
      subnet_name                  = module.virtual_networks[each.value.vnet_key].subnets[endpoint.subnet_key].name
      private_ip_allocation_method = endpoint.private_ip_allocation_method
      private_ip_address           = endpoint.private_ip_address
    }
  }
  outbound_endpoints = {
    for key, endpoint in each.value.outbound_endpoints : key => {
      name        = endpoint.name
      subnet_name = module.virtual_networks[each.value.vnet_key].subnets[endpoint.subnet_key].name
    }
  }

  enable_telemetry = each.value.enable_telemetry
  tags             = each.value.tags
}

module "firewall_policy_rule_collection_groups" {
  for_each = var.firewall_policy_rule_collection_groups

  source = "../../modules/scb_firewall_policy/v1.0.0.1/modules/rule_collection_groups"

  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policies[each.value.firewall_policy_key].resource_id
  firewall_policy_rule_collection_group_name               = each.value.name
  firewall_policy_rule_collection_group_priority           = each.value.priority

  firewall_policy_rule_collection_group_network_rule_collection = [
    for collection in each.value.network_rule_collections : {
      name     = collection.name
      action   = collection.action
      priority = collection.priority
      rule     = collection.rules
    }
  ]
  firewall_policy_rule_collection_group_application_rule_collection = [
    for collection in each.value.application_rule_collections : {
      name     = collection.name
      action   = collection.action
      priority = collection.priority
      rule     = collection.rules
    }
  ]
}

resource "azurerm_virtual_network_peering" "aigw_to_foundry" {
  name                      = "az-peer-dtx-aiplatform-aigw-to-foundry-dev-001"
  resource_group_name       = module.resource_groups["aigw_rg"].name
  virtual_network_name      = module.virtual_networks["aigw_vnet"].name
  remote_virtual_network_id = module.virtual_networks["foundry_vnet"].resource_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "foundry_to_aigw" {
  name                      = "az-peer-dtx-aiplatform-foundry-to-aigw-dev-001"
  resource_group_name       = module.resource_groups["foundry_rg"].name
  virtual_network_name      = module.virtual_networks["foundry_vnet"].name
  remote_virtual_network_id = module.virtual_networks["aigw_vnet"].resource_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}