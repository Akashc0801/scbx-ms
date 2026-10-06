variable "subscription_id" {
  type        = string
  description = "Azure subscription used by the provider for assignment dependencies and role assignments."
  default     = "3471ad5a-d8a8-4a80-b30b-668798733c14"

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be a valid Azure subscription GUID."
  }
}

variable "management_group_id" {
  type        = string
  description = "Management group ID where the SCB AI landing-zone policies are assigned."
  default     = "scb123123"

  validation {
    condition     = length(trimspace(var.management_group_id)) > 0 && !strcontains(var.management_group_id, "/")
    error_message = "management_group_id must be the management group name, not a resource ID."
  }
}

variable "assignment_location" {
  type        = string
  description = "Azure region used by policy assignments that require managed identities."
  default     = "southeastasia"
}

variable "policy_parameter_overrides" {
  type        = map(any)
  description = "Optional assignment parameter overrides keyed by full policy definition ID."
  default     = {}
}
