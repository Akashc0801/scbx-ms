# RGs, VNets, NSGs, and route tables use the SCB workload naming format:
# org-type-app_code-base_name-env-iterator.
# Other unknown values are blank; complete required values before plan/apply.

resource_groups = {
  "aigw_rg" = {
    # Naming module variables
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "rg"
    max_length           = 90
    no_dashes            = false
    add_random           = false
    rnd_length           = 4

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
    product_name        = "scb_resource_group"
    product_version     = "1.0.0.1"
    app_support         = "abc@xyz.com"

    # Optional Tags
    region               = ""
    description          = "Resource group for the AI Platform AIGW dev network"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "foundry"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "rg"
    max_length           = 90
    no_dashes            = false
    add_random           = false
    rnd_length           = 4

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
    product_name        = "scb_resource_group"
    product_version     = "1.0.0.1"
    app_support         = "abc@xyz.com"

    # Optional Tags
    region               = ""
    description          = "Resource group for the AI Platform Foundry dev network"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "apim"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "pe"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "logicapp"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "foundryagent"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "foundrype"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "build"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "nsg"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "vnet"
    max_length           = 63
    no_dashes            = false
    add_random           = false
    rnd_length           = 4

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
    service             = ""
    app_support         = "abc@xyz.com"

    # Optional Tags
    region              = ""
    description         = "VNet for the AI Platform AIGW dev network"
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
        name           = "az-snet-dtx-aiplatform-apim-dev-001"
        address_prefix = "10.0.0.0/24"
        network_security_group = {
          id = "aigw_apim_nsg" # Reference to NSG module key
        }
      }
      pe = {
        name           = "az-snet-dtx-aiplatform-pe-dev-001"
        address_prefix = "10.0.1.0/26"
        network_security_group = {
          id = "aigw_pe_nsg" # Reference to NSG module key
        }
      }
      logicapp = {
        name           = "az-snet-dtx-aiplatform-logicapp-dev-001"
        address_prefix = "10.0.1.64/26"
        network_security_group = {
          id = "aigw_logicapp_nsg" # Reference to NSG module key
        }
      }
      # Name is mandated by Azure; the subnet cannot have an NSG or route table
      firewall = {
        name           = "AzureFirewallSubnet"
        address_prefix = "10.0.1.128/26"
      }
      # Dedicated, delegated subnets (min /28) for the private DNS resolver endpoints
      dnsin = {
        name           = "az-snet-dtx-aiplatform-dnsin-dev-001"
        address_prefix = "10.0.1.192/28"
        delegations = [{
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name = "Microsoft.Network/dnsResolvers"
          }
        }]
      }
      dnsout = {
        name           = "az-snet-dtx-aiplatform-dnsout-dev-001"
        address_prefix = "10.0.1.208/28"
        delegations = [{
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name = "Microsoft.Network/dnsResolvers"
          }
        }]
      }
    }
  }

  "foundry_vnet" = {
    resource_group_key = "foundry_rg"

    # Naming module variables
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "foundry"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "vnet"
    max_length           = 63
    no_dashes            = false
    add_random           = false
    rnd_length           = 4

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
    service             = ""
    app_support         = "abc@xyz.com"

    # Optional Tags
    region              = ""
    description         = "VNet for the AI Platform Foundry dev network"
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
        name           = "az-snet-dtx-aiplatform-foundryagent-dev-001"
        address_prefix = "10.0.4.0/24"
        network_security_group = {
          id = "foundry_agent_nsg" # Reference to NSG module key
        }
        # Foundry agent network injection requires this delegation.
        delegations = [{
          name = "foundry-agents"
          service_delegation = {
            name = "Microsoft.App/environments"
          }
        }]
      }
      foundrype = {
        name           = "az-snet-dtx-aiplatform-foundrype-dev-001"
        address_prefix = "10.0.5.0/26"
        network_security_group = {
          id = "foundry_foundrype_nsg" # Reference to NSG module key
        }
      }
      build = {
        name           = "az-snet-dtx-aiplatform-build-dev-001"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "rt"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    budget_id           = ""
    status              = "Live"
    service             = ""
    app_support         = "abc@xyz.com"

    # Optional Tags
    region              = ""
    description         = "Route table for the AI Platform AIGW dev subnets"
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
        next_hop_type  = "VirtualAppliance"
        firewall_key   = "aigw_firewall"
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
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "foundry"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "rt"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform Foundry"
    budget_id           = ""
    status              = "Live"
    service             = ""
    app_support         = "abc@xyz.com"

    # Optional Tags
    region              = ""
    description         = "Route table for the AI Platform Foundry dev subnets"
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
        next_hop_type  = "VirtualAppliance"
        firewall_key   = "aigw_firewall"
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

private_dns_zones = {
  "ai_services" = {
    domain_name        = "privatelink.services.ai.azure.com"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "cognitive" = {
    domain_name        = "privatelink.cognitiveservices.azure.com"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "openai" = {
    domain_name        = "privatelink.openai.azure.com"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "blob" = {
    domain_name        = "privatelink.blob.core.windows.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "file" = {
    domain_name        = "privatelink.file.core.windows.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "cosmos_sql" = {
    domain_name        = "privatelink.documents.azure.com"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "search" = {
    domain_name        = "privatelink.search.windows.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "apim" = {
    domain_name        = "privatelink.azure-api.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "key_vault" = {
    domain_name        = "privatelink.vaultcore.azure.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "service_bus" = {
    domain_name        = "privatelink.servicebus.windows.net"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "app_config" = {
    domain_name        = "privatelink.azconfig.io"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "monitor" = {
    domain_name        = "privatelink.monitor.azure.com"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
  "container_registry" = {
    domain_name        = "privatelink.azurecr.io"
    resource_group_key = "aigw_rg"

    # Mandatory Tags
    app_name        = "AI Platform Private DNS"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_private_dns_zone"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    virtual_network_links = {
      aigw = {
        name     = "aigw-vnet-link"
        vnet_key = "aigw_vnet"
      }
      foundry = {
        name     = "foundry-vnet-link"
        vnet_key = "foundry_vnet"
      }
    }
  }
}

public_ips = {
  "aigw_firewall_pip" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = "afw"
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "pip"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    app_support         = "abc@xyz.com"
    budget_id           = ""
    status              = "Live"
    service             = ""

    # Optional Tags
    region              = ""
    description         = "Public IP for the AI Platform AIGW dev firewall"
    notification_emails = []

    # Public IP specific
    allocation_method = "Static"
    sku               = "Standard"
    sku_tier          = "Regional"
    zones             = [1, 2, 3]
  }
}

firewall_policies = {
  "aigw_firewall_policy" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "fwp"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    app_support         = "abc@xyz.com"
    product_name        = "scb_firewall_policy"
    product_version     = "1.0.0.1"
    budget_id           = ""
    status              = "Live"
    service             = ""

    # Optional Tags
    region              = ""
    description         = "Firewall policy for the AI Platform AIGW dev firewall"
    notification_emails = []

    # Firewall policy specific. The firewall tier must match the policy SKU.
    sku                      = "Standard"
    threat_intelligence_mode = "Deny"
    dns_proxy_enabled        = true
  }
}

firewalls = {
  "aigw_firewall" = {
    resource_group_key = "aigw_rg"

    # Naming module variables
    env                  = "dev"
    org                  = "az"
    naming_format        = "workload"
    location_region_code = "sea"
    base_name            = "aigw"
    additional_name      = ""
    iterator             = "001"
    au                   = "12345"
    app_code             = "dtx-aiplatform"
    bu                   = ""
    owner                = ""
    resource_type_code   = "afw"

    # Mandatory Tags
    environment         = "DEV"
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "AI Platform AIGW"
    app_support         = "abc@xyz.com"
    budget_id           = ""
    status              = "Live"
    service             = ""

    # Optional Tags
    region              = ""
    description         = "Firewall for the AI Platform AIGW dev network"
    notification_emails = []

    # Firewall specific
    firewall_sku_name   = "AZFW_VNet"
    firewall_sku_tier   = "Standard"
    firewall_zones      = ["1", "2", "3"]
    firewall_policy_key = "aigw_firewall_policy"

    ip_configurations = {
      primary = {
        name          = "ipconfig-aigw-afw"
        public_ip_key = "aigw_firewall_pip"
        vnet_key      = "aigw_vnet"
        subnet_key    = "firewall"
      }
    }
  }
}

private_dns_resolvers = {
  "aigw_dns_resolver" = {
    name               = "az-dnspr-dtx-aiplatform-aigw-dev-001"
    resource_group_key = "aigw_rg"
    vnet_key           = "aigw_vnet"

    # Mandatory Tags
    app_name        = "AI Platform AIGW"
    app_support     = "abc@xyz.com"
    business_unit   = ""
    business_owner  = ""
    product_name    = "scb_dnsresolver"
    product_version = "1.0.0.0"
    budget_id       = ""
    criticality     = ""
    environment     = "DEV"
    owner           = ""
    status          = "Live"

    inbound_endpoints = {
      inbound = {
        name       = "az-in-dtx-aiplatform-aigw-dev-001"
        subnet_key = "dnsin"
      }
    }

    outbound_endpoints = {
      outbound = {
        name       = "az-out-dtx-aiplatform-aigw-dev-001"
        subnet_key = "dnsout"
      }
    }
  }
}

firewall_policy_rule_collection_groups = {
  "aigw_rule_collection_group" = {
    firewall_policy_key = "aigw_firewall_policy"
    name                = "az-rcg-dtx-aiplatform-aigw-dev-001"
    priority            = 200

    # Dummy rules; replace with approved rules before production use
    network_rule_collections = [
      {
        name     = "az-nrc-dtx-aiplatform-aigw-dev-001"
        action   = "Allow"
        priority = 1000
        rules = [
          {
            name                  = "dummy-allow-aigw-to-foundry-https"
            description           = "Dummy network rule: AIGW VNet to Foundry VNet over HTTPS"
            protocols             = ["TCP"]
            source_addresses      = ["10.0.0.0/22"]
            destination_addresses = ["10.0.4.0/22"]
            destination_ports     = ["443"]
          },
          {
            # Foundry Agent Service: agent subnet needs Microsoft Entra ID.
            # https://learn.microsoft.com/azure/foundry/agents/how-to/virtual-networks#limitations
            name                  = "allow-foundry-agent-entra-id"
            description           = "Foundry agent subnet to Microsoft Entra ID (AzureActiveDirectory service tag) over HTTPS"
            protocols             = ["TCP"]
            source_addresses      = ["10.0.4.0/24"]
            destination_addresses = ["AzureActiveDirectory"]
            destination_ports     = ["443"]
          }
        ]
      }
    ]

    application_rule_collections = [
      {
        name     = "az-arc-dtx-aiplatform-aigw-dev-001"
        action   = "Allow"
        priority = 2000
        rules = [
          {
            name              = "dummy-allow-microsoft-https"
            description       = "Dummy application rule: AIGW and Foundry VNets to www.microsoft.com over HTTPS"
            source_addresses  = ["10.0.0.0/22", "10.0.4.0/22"]
            destination_fqdns = ["www.microsoft.com"]
            protocols = [{
              type = "Https"
              port = 443
            }]
          },
          {
            # Foundry Agent Service egress allow list (no TLS inspection).
            # https://learn.microsoft.com/azure/foundry/agents/how-to/virtual-networks#limitations
            name             = "allow-foundry-agent-identity"
            description      = "Foundry agent subnet to managed identity and Microsoft Entra ID endpoints over HTTPS"
            source_addresses = ["10.0.4.0/24"]
            destination_fqdns = [
              "control-southeastasia.identity.azure.net",
              "*.identity.azure.net",
              "southeastasia.login.microsoft.com",
              "*.login.microsoft.com",
              "login.microsoftonline.com",
              "*.login.microsoftonline.com",
            ]
            protocols = [{
              type = "Https"
              port = 443
            }]
          }
        ]
      }
    ]
  }
}
