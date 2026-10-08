# -
# Required Naming Variables
# -
variable "env" {
  type        = string
  description = "(Required) Environment identifier. Example: `p` (prod), `d` (dev), `s` (sandbox), `u` (uat)."
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "au" {
  type        = string
  description = "(Required) Gold configuration AU identifier. Example: 83254."
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: bastion, security, mgmt"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit. Example: IT, HR, FIN."
}

variable "owner" {
  type        = string
  description = "(Required) Owner identifier. Example: platform-team@example.com."
}

variable "resource_group_id" {
  type        = string
  description = "(Required) The resource ID of the resource group in which to create the bastion host."
}

# Optional naming variables
variable "org" {
  type        = string
  description = "(Optional) Organization identifier."
  default     = null
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code identifier."
  default     = "myw"
  validation {
    condition     = var.region_code == null ? true : contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
  }
}

variable "location_region_code" {
  type        = string
  description = "(Optional) SCB region code used only to select the Azure location when region_code is null. Must be one of: `[ea,sea,eu,myw,sg,idc]`."
  default     = null

  validation {
    condition     = var.location_region_code == null ? true : contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.location_region_code)
    error_message = "Value of \"location_region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
  }
}

variable "naming_format" {
  type        = string
  description = "(Optional) Naming layout passed to the SCB naming module: `legacy` (org-type-app_code-env-region-base_name) or `workload` (org-type-app_code-base_name-env-region)."
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "workload"], var.naming_format)
    error_message = "Value of \"naming_format\" must be either \"legacy\" or \"workload\"."
  }
}

variable "base_name" {
  type        = string
  description = "(Optional) Base name identifier."
  default     = null
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional name identifier."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator identifier."
  default     = "001"
}

variable "resource_type_code" {
  type        = string
  description = "(Optional) Resource type code for naming."
  default     = "bas"
}

variable "max_length" {
  type        = number
  description = "(Optional) Maximum length for naming."
  default     = null
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) Remove dashes from naming."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) Add random suffix to naming."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Length of random suffix."
  default     = 8
}

# -
# 8 Mandatory Tags for v1.0.0.1 naming module
# -
variable "business_owner" {
  type        = string
  description = "(Required) Business stakeholder accountable. Example: Head of Cloud Engineering."
}

variable "business_unit" {
  type        = string
  description = "(Required) Department owning resources. Example: GTD-ISD-CEAT."
}

variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "cost_center" {
  type        = string
  description = "(Required) Cost center for resource costs. Example: 383-80572."
}

variable "data_classification" {
  type        = string
  description = "(Required) Data sensitivity level."
}

variable "compliance" {
  type        = string
  description = "(Required) Compliance regulation."
}

# -
# 3 Optional Tags for v1.0.0.1 naming module
# -
variable "region" {
  type        = string
  description = "(Optional) Country or region. Example: MYW, SEA."
  default     = null
}

variable "description" {
  type        = string
  description = "(Optional) Purpose of resource/workload. Example: Bastion host for secure access."
  default     = null
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) Email list for alerts. Example: [\"mss_ceat@example.com\"]."
  default     = []
}

# -
# Resource Group + Workload Mandatory Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human-readable application name. Example: SCB-BastionHost."
}

variable "budget_id" {
  type        = string
  description = "(Required) GL or budget reference. Example: 83254."
}

variable "status" {
  type        = string
  description = "(Required) Lifecycle state."
}

# Product name and version are hardcoded in main.tf

variable "service" {
  type        = string
  description = "(Required) Sub-component or functional module."
}

# -
# Workload Optional Tags
# -
variable "app_id" {
  type        = string
  description = "(Optional) Application identifier from CMDB. Example: SCB-MYW-SEC01-00001."
  default     = ""
}

variable "auto_delete" {
  type        = string
  description = "(Optional) Auto-delete indicator."
  default     = ""
}

variable "delete_after" {
  type        = string
  description = "(Optional) Scheduled deletion date. Example: 12/31/2025."
  default     = ""
}

variable "integration_id" {
  type        = string
  description = "(Optional) SaaS/external connector identifier. Example: Bastion-terraform-mod."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Data retention duration. Example: 30, 0."
  default     = ""
}

variable "experiment_phase" {
  type        = string
  description = "(Optional) Experimentation phase."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox."
  default     = ""
}

variable "os" {
  type        = string
  description = "(Optional) Operating system for VMs."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy. Example: Monthly-Standard."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Patch frequency window. Example: Sun-02:00Z."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Timestamp of last VM access."
  default     = ""
}

# -
# Additional Tags
# -
variable "additional_tags" {
  type        = map(string)
  description = "(Optional) Additional custom tags."
  default     = {}
}

# -
# Bastion Host Configuration Variables
# -
variable "sku" {
  type        = string
  description = "(Optional) The SKU of the bastion host. Possible values are Basic, Standard, Premium, and Developer."
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium", "Developer"], var.sku)
    error_message = "Value of \"sku\" must be one of: [Basic,Standard,Premium,Developer]."
  }
}

variable "zones" {
  type        = list(string)
  description = "(Optional) Availability zones for the bastion host. Possible values are 1, 2, and 3."
  default     = ["1", "2", "3"]
  validation {
    condition = alltrue([
      for zone in var.zones : contains(["1", "2", "3"], zone)
    ])
    error_message = "All zones must be one of: [\"1\",\"2\",\"3\"]."
  }
}

variable "copy_paste_enabled" {
  type        = bool
  description = "(Optional) Is copy and paste feature enabled for the bastion host."
  default     = true
}

variable "file_copy_enabled" {
  type        = bool
  description = "(Optional) Is file copy feature enabled for the bastion host."
  default     = false
}

variable "ip_connect_enabled" {
  type        = bool
  description = "(Optional) Is IP connect feature enabled for the bastion host."
  default     = false
}

variable "kerberos_enabled" {
  type        = bool
  description = "(Optional) Is kerberos authentication feature enabled for the bastion host."
  default     = false
}

variable "private_only_enabled" {
  type        = bool
  description = "(Optional) Is private only bastion host enabled."
  default     = false
}

variable "session_recording_enabled" {
  type        = bool
  description = "(Optional) Is session recording feature enabled for the bastion host."
  default     = false
}

variable "shareable_link_enabled" {
  type        = bool
  description = "(Optional) Is shareable link feature enabled for the bastion host."
  default     = false
}

variable "tunneling_enabled" {
  type        = bool
  description = "(Optional) Is tunneling feature enabled for the bastion host."
  default     = false
}

variable "scale_units" {
  type        = number
  description = "(Optional) The number of scale units for the bastion host. Value between 2 and 50."
  default     = 2
  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Value of \"scale_units\" must be between 2 and 50."
  }
}

variable "virtual_network_id" {
  type        = string
  description = "(Optional) The ID of the virtual network for Developer SKU bastion host."
  default     = null
}

variable "ip_configuration" {
  type = object({
    name                             = optional(string)
    subnet_id                        = string
    create_public_ip                 = optional(bool, true)
    public_ip_address_name           = optional(string)
    public_ip_address_id             = optional(string)
    public_ip_tags                   = optional(map(string))
    public_ip_merge_with_module_tags = optional(bool, true)
  })
  description = "(Optional) IP configuration for the bastion host."
  default     = null
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  description = "(Optional) Controls the Resource Lock configuration for this resource."
  default     = null
  validation {
    condition = var.lock != null ? contains([
      "CanNotDelete", "ReadOnly"
    ], var.lock.kind) : true
    error_message = "Value of \"lock.kind\" must be one of: [CanNotDelete,ReadOnly]."
  }
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), [])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  description = "(Optional) A map of diagnostic settings to create on the bastion host."
  default     = {}
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  description = "(Optional) A map of role assignments to create on the bastion host."
  default     = {}
}

variable "enable_telemetry" {
  type        = bool
  description = "(Optional) This variable controls whether or not telemetry is enabled for the module."
  default     = true
}

variable "type" {
  type        = string
  description = "(Required) Infrastructure or business service type."
  default     = "Infrastructure"
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  default     = "No"
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "review_required" {
  type        = string
  description = "(Optional) Review requirement."
  default     = ""
}

variable "budget_limit" {
  type        = string
  description = "(Required) Maximum budget allocated."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Resource tier."
  default     = ""
}

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  default     = ""
}

variable "disaster_recovery" {
  type        = string
  description = "(Optional) Disaster recovery configuration."
  default     = ""
}

variable "automation_policy" {
  type        = string
  description = "(Optional) Reference to any automation policy."
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the resource."
}