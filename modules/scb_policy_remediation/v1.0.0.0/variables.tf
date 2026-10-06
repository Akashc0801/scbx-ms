variable "name" {
  description = "The name of the remediation."
  type        = string
}

variable "scope" {
  description = "The scope at which the remediation will be created. Can be management group ID, subscription ID, resource group ID, or resource ID."
  type        = string
}

variable "policy_assignment_id" {
  description = "The ID of the policy assignment to remediate."
  type        = string
}

variable "policy_definition_reference_id" {
  description = "The policy definition reference ID within a policy set definition to remediate. Optional for individual policy assignments."
  type        = string
  default     = null
}

variable "policy_definition_reference_ids" {
  description = "List of policy definition reference IDs within a policy set definition to remediate. Creates multiple remediation resources. Cannot be used with policy_definition_reference_id."
  type        = list(string)
  default     = []
}

variable "location_filters" {
  description = "A list of the resource locations that will be remediated."
  type        = list(string)
  default     = null
}

variable "resource_discovery_mode" {
  description = "The resource discovery mode for the remediation. Possible values are ExistingNonCompliant, ReEvaluateCompliance. Default is ExistingNonCompliant."
  type        = string
  default     = "ExistingNonCompliant"
  validation {
    condition = contains([
      "ExistingNonCompliant",
      "ReEvaluateCompliance"
    ], var.resource_discovery_mode)
    error_message = "The resource_discovery_mode must be one of: ExistingNonCompliant, ReEvaluateCompliance."
  }
}

variable "failure_percentage" {
  description = "A percentage between 0.0 to 1.0 of how many resources are allowed to fail the remediation before it is canceled. Defaults to 0.1 (10%)."
  type        = number
  default     = 0.1
  validation {
    condition     = var.failure_percentage >= 0.0 && var.failure_percentage <= 1.0
    error_message = "The failure_percentage must be between 0.0 and 1.0."
  }
}

variable "parallel_deployments" {
  description = "How many resources to remediate at any given time. Must be between 1 and 30. Defaults to 10."
  type        = number
  default     = 10
  validation {
    condition     = var.parallel_deployments >= 1 && var.parallel_deployments <= 30
    error_message = "The parallel_deployments must be between 1 and 30."
  }
}

variable "resource_count" {
  description = "Determines how many resources to remediate at any given time. Can be used to limit the impact of a remediation request."
  type        = number
  default     = null
}
