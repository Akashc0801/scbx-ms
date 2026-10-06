# Variables for Key Vault Audit Policy Deployment

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "your-workspace"
}

variable "log_analytics_resource_group" {
  description = "Resource group containing the Log Analytics workspace"
  type        = string
  default     = "monitoring-rg"
}

variable "policy_assignment_location" {
  description = "Location for the policy assignment"
  type        = string
  default     = "southeastasia"
}

variable "policy_enforcement_mode" {
  description = "Policy enforcement mode"
  type        = string
  default     = "Default"

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.policy_enforcement_mode)
    error_message = "Policy enforcement mode must be either 'Default' or 'DoNotEnforce'."
  }
}

variable "policy_effect" {
  description = "Effect of the policy"
  type        = string
  default     = "DeployIfNotExists"

  validation {
    condition     = contains(["DeployIfNotExists", "AuditIfNotExists", "Disabled"], var.policy_effect)
    error_message = "Policy effect must be one of: DeployIfNotExists, AuditIfNotExists, Disabled."
  }
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  type        = string
  default     = "setByPolicy-LogAnalytics"
}

variable "resource_location_list" {
  description = "List of allowed resource locations (use ['*'] for all locations)"
  type        = list(string)
  default     = ["*"]
}