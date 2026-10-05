#=================================================================
# Terraform module for Azure API Management Logger
# =================================================================

variable "logger_name" {
  description = "Name of the APIM logger"
  type        = string
}

variable "apim_name" {
  description = "Name of the API Management instance"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where APIM exists"
  type        = string
}

variable "app_insights_instrumentation_key" {
  description = "Instrumentation key of Application Insights"
  type        = string
}

# -
# Basic Naming Parameters
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "org" {
  type        = string
  description = "(Optional) Company/Business unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code. Example: `sea`."
  default     = null
}

variable "base_name" {
  type        = string
  description = "(Optional) Application/Infrastructure base name. Example: `aks`."
  default     = null
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness. Example: `lan1`."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness. Example: `001`."
  default     = null
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit code. Example: `0233985`."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value must be numeric characters."
  }
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build."
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or mbb."
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation. Example: `ampls`."
  default     = "ampls"
}

variable "max_length" {
  type        = number
  description = "(Optional) Maximum length of generated name."
  default     = 63
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) Remove dashes in generated name."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) Add random characters to name."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Length of random string."
  default     = 2
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Application name."
  default     = "DefaultAppName"
}

variable "app_support" {
  type        = string
  description = "(Required) Application support contact."
  default     = "DefaultAppSupport"
}

variable "business_unit" {
  type        = string
  description = "(Required) Business unit name."
  default     = "DefaultBusinessUnit"
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "type" {
  type        = string
  description = "(Required) Infrastructure or business service type."
  default     = "Infrastructure"
}

# -
# Mandatory DevOps Tags
# -
variable "product_name" {
  type        = string
  description = "(Required) Product name."
  default     = "DefaultProductName"
}

variable "product_version" {
  type        = string
  description = "(Required) Product version."
  default     = "DefaultProductVersion"
}

# -
# Mandatory Finance Tags
# -
variable "cost_center" {
  type        = string
  description = "(Required) Cost center."
  default     = ""
}

variable "cost_allocation_unit" {
  type        = string
  default     = ""
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  default     = ""
  description = "(Required) Maximum budget allocated."
}

variable "cost_alert_threshold" {
  type        = string
  default     = ""
  description = "(Required) Cost threshold for triggering alerts."
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  description = "(Required) Data classification."
  default     = "DefaultClassification"
}

variable "compliance_required" {
  type        = string
  description = "(Required) Compliance required."
  default     = "DefaultCompliance"
}

variable "compliance" {
  type        = string
  description = "(Required) Compliance standard."
  default     = "DefaultCompliance"
}

# -
# Mandatory Operation Tags
# -
variable "criticality" {
  type        = string
  description = "(Required) Resource criticality."
  default     = "DefaultCriticality"
}

variable "environment" {
  type        = string
  description = "(Required) Environment name."
  default     = "DefaultEnvironment"
}

variable "status" {
  type        = string
  description = "(Required) Resource status."
  default     = "DefaultStatus"
}

# -
# Optional Tags
# -
variable "delete_after" {
  type        = string
  description = "(Optional) Resource deletion date."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Resource tier."
  default     = ""
}

variable "app_id" {
  type        = string
  description = "(Optional) Application ID."
  default     = ""
}

variable "auto_delete" {
  type        = string
  description = "(Optional) Auto-delete configuration."
  default     = ""
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Resource description."
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

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window frequency."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of email addresses for notifications."
  default     = []
  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All notification emails must be valid email addresses."
  }
}

variable "region" {
  type        = string
  description = "(Optional) Geographic region of the resource."
  default     = ""
}

variable "integration_id" {
  type        = string
  description = "(Optional) Integration ID for the resource."
  default     = ""
}

variable "experiment_phase" {
  type        = string
  description = "(Optional) Experiment phase for the resource."
  default     = ""
}

variable "os" {
  type        = string
  description = "(Optional) Operating system type."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Last VM access timestamp."
  default     = ""
}

variable "service" {
  type        = string
  description = "(Optional) Service name."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Data retention policy."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Sandbox type."
  default     = ""
}

variable "additional_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Additional tags to merge with module tags."
}

variable "review_required" {
  type        = string
  description = "(Optional) Review requirement."
  default     = ""
}