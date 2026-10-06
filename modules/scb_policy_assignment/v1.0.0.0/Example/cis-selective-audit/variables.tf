# Variables for CIS Selective Audit Policy Assignment

variable "policy_assignment_location" {
  description = "Azure region where the policy assignment will be created"
  type        = string
  default     = "southeastasia"
}

variable "policy_enforcement_mode" {
  description = "Enforcement mode for the policy assignment. Can be 'Default' or 'DoNotEnforce'"
  type        = string
  default     = "Default"

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.policy_enforcement_mode)
    error_message = "Enforcement mode must be either 'Default' or 'DoNotEnforce'."
  }
}