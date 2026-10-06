variable "management_group_id" {
  type        = string
  description = "Management group ID where all SCB AI landing zone policies are assigned."
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
