variable "resource_groups" {
  description = "Map of resource group definitions. The key is referenced by the other resources."
  type = map(object({
    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string, null)
    location_region_code = optional(string, null)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = string
    max_length           = optional(number, 90)
    no_dashes            = optional(bool, false)
    add_random           = optional(bool, false)
    rnd_length           = optional(number, 4)

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    budget_id           = string
    status              = string
    product_name        = string
    product_version     = string
    app_support         = string

    # Optional Tags
    region               = optional(string, "")
    description          = optional(string, "")
    notification_emails  = optional(list(string), [])
    automation_policy    = optional(string, "")
    review_required      = optional(string, "")
    backup_policy        = optional(string, "")
    disaster_recovery    = optional(string, "")
    cost_alert_threshold = optional(string, "")
    budget_limit         = optional(string, "")

    lock             = optional(any)
    role_assignments = optional(any)
    additional_tags  = optional(map(string))
  }))
}

variable "network_security_groups" {
  description = "Map of network security groups. Each is attached to one subnet through virtual_networks."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string)
    location_region_code = optional(string)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = string

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    budget_id           = string
    status              = string
    service             = string

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])
    app_id              = optional(string, "")
    auto_delete         = optional(string, "")
    delete_after        = optional(string, "")
    integration_id      = optional(string, "")
    retention           = optional(string, "")
    experiment_phase    = optional(string, "")
    sandbox_type        = optional(string, "")
    os                  = optional(string, "")
    patch_policy        = optional(string, "")
    maintenance_window  = optional(string, "")
    last_vm_accessed    = optional(string, "")

    security_rules = optional(map(object({
      access                                     = string
      description                                = optional(string)
      destination_address_prefix                 = optional(string)
      destination_address_prefixes               = optional(set(string))
      destination_application_security_group_ids = optional(set(string))
      destination_port_range                     = optional(string)
      destination_port_ranges                    = optional(set(string))
      direction                                  = string
      name                                       = string
      priority                                   = number
      protocol                                   = string
      source_address_prefix                      = optional(string)
      source_address_prefixes                    = optional(set(string))
      source_application_security_group_ids      = optional(set(string))
      source_port_range                          = optional(string)
      source_port_ranges                         = optional(set(string))
    })), {})
  }))
}

variable "virtual_networks" {
  description = "Map of virtual networks and their subnets."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string, null)
    location_region_code = optional(string, null)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = string
    max_length           = optional(number, 63)
    no_dashes            = optional(bool, false)
    add_random           = optional(bool, false)
    rnd_length           = optional(number, 4)

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    budget_id           = string
    status              = string
    service             = string
    app_support         = string

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])
    app_id              = optional(string, "")
    auto_delete         = optional(string, "")
    delete_after        = optional(string, "")
    integration_id      = optional(string, "")
    retention           = optional(string, "")
    experiment_phase    = optional(string, "")
    sandbox_type        = optional(string, "")
    os                  = optional(string, "")
    patch_policy        = optional(string, "")
    maintenance_window  = optional(string, "")
    last_vm_accessed    = optional(string, "")

    # Network specific
    address_space = list(string)
    subnets = map(object({
      name           = string
      address_prefix = string
      network_security_group = optional(object({
        id = string
      }))
      delegations = optional(list(object({
        name = string
        service_delegation = object({
          name = string
        })
      })))
    }))

    lock             = optional(any)
    role_assignments = optional(any)
    additional_tags  = optional(map(string))
  }))

  validation {
    condition = alltrue(flatten([
      for vnet in values(var.virtual_networks) : concat(
        [for prefix in vnet.address_space : can(cidrhost(prefix, 0))],
        [for subnet in values(vnet.subnets) : can(cidrhost(subnet.address_prefix, 0))]
      )
    ]))
    error_message = "Every VNet address_space and subnet address_prefix must be a valid CIDR prefix."
  }
}

variable "route_tables" {
  description = "Map of route tables and the subnets they are associated with."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string)
    location_region_code = optional(string)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = string

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    budget_id           = string
    status              = string
    service             = string
    app_support         = string

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])
    app_id              = optional(string, "")
    auto_delete         = optional(string, "")
    delete_after        = optional(string, "")
    integration_id      = optional(string, "")
    retention           = optional(string, "")
    experiment_phase    = optional(string, "")
    sandbox_type        = optional(string, "")
    os                  = optional(string, "")
    patch_policy        = optional(string, "")
    maintenance_window  = optional(string, "")
    last_vm_accessed    = optional(string, "")

    # Route table specific variables
    bgp_route_propagation_enabled = optional(bool, true)
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
    subnet_associations = map(object({
      vnet_key   = string
      subnet_key = string
    }))

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}

variable "private_dns_zones" {
  description = "Map of private DNS zones. Each zone is linked to the VNets listed in virtual_network_links."
  type = map(object({
    domain_name        = string
    resource_group_key = string

    # Mandatory Tags
    app_name        = string
    app_support     = string
    business_unit   = string
    business_owner  = string
    product_name    = optional(string, "scb_private_dns_zone")
    product_version = string
    budget_id       = string
    criticality     = string
    environment     = string
    owner           = string
    status          = string

    virtual_network_links = map(object({
      name                 = string
      vnet_key             = string
      registration_enabled = optional(bool, false)
    }))

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}

variable "public_ips" {
  description = "Map of public IPs, typically used by the firewall ip_configuration."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string)
    location_region_code = optional(string)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = optional(string, "pip")

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    app_support         = string
    budget_id           = string
    status              = string
    service             = string

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])

    # Public IP specific
    allocation_method = optional(string, "Static")
    sku               = optional(string, "Standard")
    sku_tier          = optional(string, "Regional")
    zones             = optional(set(number), [1, 2, 3])

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}

variable "firewall_policies" {
  description = "Map of Azure Firewall policies."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string)
    location_region_code = optional(string)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = optional(string, "fwp")

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    app_support         = string
    product_name        = optional(string, "scb_firewall_policy")
    product_version     = optional(string, "1.0.0.1")
    budget_id           = string
    status              = string
    service             = optional(string, "")

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])

    # Firewall policy specific
    sku                      = optional(string, "Standard")
    threat_intelligence_mode = optional(string, "Deny")
    dns_proxy_enabled        = optional(bool, true)
    dns_servers              = optional(list(string))

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}

variable "firewalls" {
  description = "Map of Azure Firewalls. Policy, public IP, and subnet are referenced by module keys."
  type = map(object({
    resource_group_key = string

    # Naming module variables
    env                  = string
    org                  = string
    region_code          = optional(string)
    location_region_code = optional(string)
    naming_format        = optional(string, "legacy")
    base_name            = optional(string, "")
    additional_name      = optional(string, "")
    iterator             = string
    au                   = string
    app_code             = string
    bu                   = string
    owner                = string
    resource_type_code   = optional(string, "afw")

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    app_support         = string
    budget_id           = string
    status              = string
    service             = optional(string, "")

    # Optional Tags
    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])

    # Firewall specific
    firewall_sku_name   = optional(string, "AZFW_VNet")
    firewall_sku_tier   = optional(string, "Standard")
    firewall_zones      = optional(set(string), ["1", "2", "3"])
    firewall_policy_key = string
    # Exactly one configuration must reference the AzureFirewallSubnet (vnet_key + subnet_key)
    ip_configurations = map(object({
      name          = string
      public_ip_key = string
      vnet_key      = optional(string)
      subnet_key    = optional(string)
    }))

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}
variable "private_dns_resolvers" {
  description = "Map of private DNS resolvers with inbound and outbound endpoints placed in delegated subnets of the referenced VNet."
  type = map(object({
    name               = string
    resource_group_key = string
    vnet_key           = string

    # Mandatory Tags
    app_name        = string
    app_support     = string
    business_unit   = string
    business_owner  = string
    product_name    = optional(string, "scb_dnsresolver")
    product_version = string
    budget_id       = string
    criticality     = string
    environment     = string
    owner           = string
    status          = string

    inbound_endpoints = optional(map(object({
      name                         = string
      subnet_key                   = string
      private_ip_allocation_method = optional(string, "Dynamic")
      private_ip_address           = optional(string)
    })), {})
    outbound_endpoints = optional(map(object({
      name       = string
      subnet_key = string
    })), {})

    enable_telemetry = optional(bool, true)
    tags             = optional(map(string), {})
  }))
}

variable "firewall_policy_rule_collection_groups" {
  description = "Map of firewall policy rule collection groups with network and application rule collections."
  type = map(object({
    firewall_policy_key = string
    name                = string
    priority            = number

    network_rule_collections = optional(list(object({
      name     = string
      action   = string
      priority = number
      rules = list(object({
        name                  = string
        description           = optional(string)
        protocols             = list(string)
        source_addresses      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_ports     = list(string)
      }))
    })), [])

    application_rule_collections = optional(list(object({
      name     = string
      action   = string
      priority = number
      rules = list(object({
        name              = string
        description       = optional(string)
        source_addresses  = optional(list(string), [])
        destination_fqdns = optional(list(string), [])
        protocols = list(object({
          type = string
          port = number
        }))
      }))
    })), [])
  }))
}