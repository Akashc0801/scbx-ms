variable "resource_groups" {
  description = "Map of resource group definitions. The key is referenced by the other resources."
  type = map(object({
    # Naming module variables
    env                = string
    org                = string
    region_code        = string
    base_name          = optional(string, "")
    additional_name    = optional(string, "")
    iterator           = string
    au                 = string
    app_code           = string
    bu                 = string
    owner              = string
    resource_type_code = string
    max_length         = optional(number, 90)
    no_dashes          = optional(bool, false)
    add_random         = optional(bool, false)
    rnd_length         = optional(number, 4)

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
    env                = string
    org                = string
    region_code        = string
    base_name          = optional(string, "")
    additional_name    = optional(string, "")
    iterator           = string
    au                 = string
    app_code           = string
    bu                 = string
    owner              = string
    resource_type_code = string

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
    env                = string
    org                = string
    region_code        = string
    base_name          = optional(string, "")
    additional_name    = optional(string, "")
    iterator           = string
    au                 = string
    app_code           = string
    bu                 = string
    owner              = string
    resource_type_code = string
    max_length         = optional(number, 63)
    no_dashes          = optional(bool, false)
    add_random         = optional(bool, false)
    rnd_length         = optional(number, 4)

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
    env                = string
    org                = string
    region_code        = string
    base_name          = optional(string, "")
    additional_name    = optional(string, "")
    iterator           = string
    au                 = string
    app_code           = string
    bu                 = string
    owner              = string
    resource_type_code = string

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

variable "nprd_values_verified" {
  description = "Set true only after the blank values in variables.tfvars are completed and the plan is reviewed."
  type        = bool
  default     = false
}
