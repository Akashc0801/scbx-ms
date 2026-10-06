# Naming follows the SCB naming module: org-type-app_code-env-region_code-base_name-iterator.
# Values that are not yet known are left blank and must be completed before apply.

resource_groups = {
  "aigw_rg" = {
    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "aigw"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    product_name        = "scb_resource_group"
    product_version     = "1.0.0.1"
    app_support         = ""

    # Optional Tags
    region               = ""
    description          = "Resource group for the AI Platform AIGW NPRD network"
    notification_emails  = []
    automation_policy    = ""
    review_required      = ""
    backup_policy        = ""
    disaster_recovery    = ""
    cost_alert_threshold = ""
    budget_limit         = ""
  }

  "foundry_rg" = {
    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "foundry"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    product_name        = "scb_resource_group"
    product_version     = "1.0.0.1"
    app_support         = ""

    # Optional Tags
    region               = ""
    description          = "Resource group for the AI Platform Foundry NPRD network"
    notification_emails  = []
    automation_policy    = ""
    review_required      = ""
    backup_policy        = ""
    disaster_recovery    = ""
    cost_alert_threshold = ""
    budget_limit         = ""
  }
}

network_security_groups = {
  "aigw_apim_nsg" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "apim"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the apim subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }

  "aigw_pe_nsg" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "pe"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the pe subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }

  "aigw_logicapp_nsg" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "logicapp"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the logicapp subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }

  "foundry_agent_nsg" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "agent"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the agent subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }

  "foundry_foundrype_nsg" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "foundrype"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the foundrype subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }

  "foundry_build_nsg" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "build"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "NSG for the build subnet"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Custom security rules are not defined yet
    security_rules = {}
  }
}

virtual_networks = {
  "aigw_vnet" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "aigw"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "vnet"
    max_length         = 63
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    service             = ""
    app_support         = ""

    # Optional Tags
    region              = ""
    description         = "VNet for the AI Platform AIGW NPRD network"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Network specific
    address_space = ["10.0.0.0/22"]

    subnets = {
      apim = {
        name           = "az-snet-sbx-aiplatform-apim-nprd-001"
        address_prefix = "10.0.0.0/24"
        network_security_group = {
          id = "aigw_apim_nsg" # Reference to NSG module key
        }
      }
      pe = {
        name           = "az-snet-sbx-aiplatform-pe-nprd-001"
        address_prefix = "10.0.1.0/26"
        network_security_group = {
          id = "aigw_pe_nsg" # Reference to NSG module key
        }
      }
      logicapp = {
        name           = "az-snet-sbx-aiplatform-logicapp-nprd-001"
        address_prefix = "10.0.1.64/26"
        network_security_group = {
          id = "aigw_logicapp_nsg" # Reference to NSG module key
        }
      }
    }
  }

  "foundry_vnet" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "foundry"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "vnet"
    max_length         = 63
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    service             = ""
    app_support         = ""

    # Optional Tags
    region              = ""
    description         = "VNet for the AI Platform Foundry NPRD network"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Network specific
    address_space = ["10.0.4.0/22"]

    subnets = {
      agent = {
        name           = "az-snet-sbx-aiplatform-agent-nprd-001"
        address_prefix = "10.0.4.0/24"
        network_security_group = {
          id = "foundry_agent_nsg" # Reference to NSG module key
        }
      }
      foundrype = {
        name           = "az-snet-sbx-aiplatform-foundrype-nprd-001"
        address_prefix = "10.0.5.0/26"
        network_security_group = {
          id = "foundry_foundrype_nsg" # Reference to NSG module key
        }
      }
      build = {
        name           = "az-snet-sbx-aiplatform-build-nprd-001"
        address_prefix = "10.0.5.64/27"
        network_security_group = {
          id = "foundry_build_nsg" # Reference to NSG module key
        }
      }
    }
  }
}

route_tables = {
  "aigw_route_table" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "aigw"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "rt"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = ""
    service             = ""
    app_support         = ""

    # Optional Tags
    region              = ""
    description         = "Route table for the AI Platform AIGW NPRD subnets"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Route table specific configuration
    bgp_route_propagation_enabled = true

    routes = {
      default_to_internet = {
        name           = "default-to-internet"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    }

    # Subnet associations
    subnet_associations = {
      apim = {
        vnet_key   = "aigw_vnet"
        subnet_key = "apim"
      }
      pe = {
        vnet_key   = "aigw_vnet"
        subnet_key = "pe"
      }
      logicapp = {
        vnet_key   = "aigw_vnet"
        subnet_key = "logicapp"
      }
    }
  }

  "foundry_route_table" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                = "np"
    org                = "scb"
    region_code        = "sea"
    base_name          = "foundry"
    additional_name    = ""
    iterator           = "001"
    au                 = ""
    app_code           = "aiplatform"
    bu                 = ""
    owner              = ""
    resource_type_code = "rt"

    # Mandatory Tags
    environment         = "NPRD"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = ""
    service             = ""
    app_support         = ""

    # Optional Tags
    region              = ""
    description         = "Route table for the AI Platform Foundry NPRD subnets"
    notification_emails = []
    app_id              = ""
    auto_delete         = ""
    delete_after        = ""
    integration_id      = ""
    retention           = ""
    experiment_phase    = ""
    sandbox_type        = ""
    os                  = ""
    patch_policy        = ""
    maintenance_window  = ""
    last_vm_accessed    = ""

    # Route table specific configuration
    bgp_route_propagation_enabled = true

    routes = {
      default_to_internet = {
        name           = "default-to-internet"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    }

    # Subnet associations
    subnet_associations = {
      agent = {
        vnet_key   = "foundry_vnet"
        subnet_key = "agent"
      }
      foundrype = {
        vnet_key   = "foundry_vnet"
        subnet_key = "foundrype"
      }
      build = {
        vnet_key   = "foundry_vnet"
        subnet_key = "build"
      }
    }
  }
}

nprd_values_verified = false
