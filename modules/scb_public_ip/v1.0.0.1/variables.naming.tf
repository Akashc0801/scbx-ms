# -
# Basic Naming Parameters
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "org" {
  type        = string
  description = "(Optional) Company/Business unit code. Example: `scb`."
  default     = "scb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code. Example: `sea`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw", "idc"], var.region_code)
    error_message = "Value must be one of: [ea,sea,eu,myw,idc]."
  }
  default = "sea"
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
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or scb."
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation."
  default     = "pip"
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
# Mandatory Finance Tags
# -
variable "cost_allocation_unit" {
  type        = string
  description = "(Optional) Logical bucket to split shared platform cost."
  default     = ""
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  description = "(Optional) Maximum budget allocated."
  default     = ""
}

variable "cost_alert_threshold" {
  type        = string
  description = "(Optional) Cost threshold for triggering alerts."
  default     = ""
}

# -
# Additional Tags
# -
variable "additional_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to resources"
  default     = {}
}

# -
# Optional Operation Tags
# -
variable "disaster_recovery" {
  type        = string
  description = "(Optional) DR requirements."
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

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  validation {
    condition     = var.backup_policy == "" || contains(["Manual", "Policy Based"], var.backup_policy)
    error_message = "Value must be one of: Manual, Policy Based."
  }
  default = ""
}

variable "region" {
  type        = string
  description = "(Required) Azure region where the resource is deployed."
}

variable "description" {
  type        = string
  description = "(Optional) Brief description of the resource purpose."
  default     = ""
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "country" {
  type        = string
  description = "(Optional) Country code. Example: `sea`."
  default     = ""
}

# -
# Mandatory Governance Tags
# -
variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
  default     = "None"
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  validation {
    condition     = contains(["Yes", "No"], var.compliance_required)
    error_message = "Value must be Yes or No."
  }
  default = "No"
}

variable "status" {
  type        = string
  description = "(Required) Status of the resource."
  validation {
    condition     = contains(["Live", "Non-Operational", "Decommissioned"], var.status)
    error_message = "Value must be one of: Live, Non-Operational, Decommissioned."
  }
  default = "Live"
}