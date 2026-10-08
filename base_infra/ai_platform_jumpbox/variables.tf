variable "common" {
  description = "Naming-module inputs and tags shared by every resource in this stack (same layout as base_infra/ai_platform_foundry)."
  type = object({
    org                  = string
    env                  = string
    app_code             = string
    naming_format        = optional(string, "workload")
    region_code          = optional(string)
    location_region_code = optional(string, "sea")
    au                   = string
    bu                   = string
    owner                = string

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

    region              = optional(string, "")
    description         = optional(string, "")
    notification_emails = optional(list(string), [])
    additional_tags     = optional(map(string), {})
  })
}

variable "network" {
  description = "Foundry VNet and build subnet created by base_infra/ai_platform_network."
  type = object({
    virtual_network_name                = string
    virtual_network_resource_group_name = string
    build_subnet_name                   = string
  })
}

variable "jumpbox" {
  description = "Jump box VM settings."
  type = object({
    base_name      = optional(string, "jumpbox")
    iterator       = optional(string, "001")
    computer_name  = optional(string, "aifjumpbox01")
    sku_size       = optional(string, "Standard_D2s_v5")
    zone           = optional(string, "1")
    admin_username = optional(string, "aifadmin")
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
      }), {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-azure-edition"
      version   = "latest"
    })
    shutdown_time     = optional(string, "2000")
    shutdown_timezone = optional(string, "SE Asia Standard Time")
  })
  default = {}
}
