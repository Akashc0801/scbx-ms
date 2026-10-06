variable "name" {
  description = "The name of the policy exemption."
  type        = string
}

variable "scope" {
  description = "The scope at which the exemption will be created. Can be management group ID, subscription ID, resource group ID, or resource ID. Use scopes for multiple resources."
  type        = string
  default     = null
}

variable "scopes" {
  description = "List of scopes at which exemptions will be created. Use this to exempt multiple resources."
  type        = list(string)
  default     = []
  validation {
    condition     = (var.scope != null || length(var.scopes) > 0) && !(length(var.scopes) > 0 && var.scope != null)
    error_message = "Provide either scope or scopes (one must be set), not both."
  }
}

variable "policy_assignment_id" {
  description = "The ID of the policy assignment being exempted."
  type        = string
}

variable "exemption_category" {
  description = "The category of the exemption. Possible values are Waiver or Mitigated."
  type        = string
  validation {
    condition     = contains(["Waiver", "Mitigated"], var.exemption_category)
    error_message = "The exemption_category must be either 'Waiver' or 'Mitigated'."
  }
}

variable "display_name" {
  description = "The display name for the exemption."
  type        = string
  default     = null
}

variable "description" {
  description = "A description for the exemption."
  type        = string
  default     = null
}

variable "expires_on" {
  description = "The expiration date of the exemption in RFC3339 format (e.g., 2026-12-31T23:59:59Z)."
  type        = string
  default     = null
}

variable "metadata" {
  description = "A JSON mapping of any metadata for this exemption."
  type        = any
  default     = null
}

variable "policy_definition_reference_id" {
  description = "The policy definition reference ID within a policy set definition to exempt. Optional for individual policy assignments."
  type        = string
  default     = null
}

variable "policy_definition_reference_ids" {
  description = "List of policy definition reference IDs within a policy set definition to exempt. Creates multiple exemptions. Cannot be used with policy_definition_reference_id."
  type        = list(string)
  default     = []
}
