variable "subscription_id" {
  type        = string
  description = "Provider subscription for existing dependencies; assignments are at management-group scope."

  validation {
    condition = (
      can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.subscription_id)) &&
      var.subscription_id != "00000000-0000-0000-0000-000000000000"
    )
    error_message = "Replace subscription_id with a real Azure subscription GUID."
  }
}

variable "management_group_ids" {
  type = object({
    ai_nonprod = string
    ai_gateway = string
    ai_agent   = string
  })
  description = "Existing management-group IDs, not display names. The hierarchy is not created by this stack."

  validation {
    condition = alltrue([
      for id in values(var.management_group_ids) :
      length(trimspace(id)) > 0 && !strcontains(id, "/") && !startswith(id, "REPLACE_")
    ]) && length(distinct(values(var.management_group_ids))) == 3
    error_message = "Supply three distinct existing management-group IDs; replace all placeholders."
  }
}

variable "assignment_location" {
  type        = string
  default     = "southeastasia"
  description = "Azure region for the system-assigned policy identities."
}

variable "policy_parameter_overrides" {
  type        = any
  default     = {}
  description = "Assignment parameters keyed by assignment_key from policies.json, with values shaped as { value = ... }."

  validation {
    condition = can(keys(var.policy_parameter_overrides)) && alltrue([
      for key, parameters in var.policy_parameter_overrides :
      contains(keys(local.policies), key) && can(keys(parameters))
    ])
    error_message = "Overrides must be an object keyed by known assignment_key values, containing parameter objects."
  }

  validation {
    condition = alltrue(flatten([
      for key, policy in local.policies : [
        for parameter in policy.required_parameters :
        try(
          length(var.policy_parameter_overrides[key][parameter].value) > 0 &&
          !strcontains(jsonencode(var.policy_parameter_overrides[key][parameter].value), "REPLACE_"),
          false
        )
      ]
    ]))
    error_message = "Supply every required parameter listed in policies.json. Empty values and REPLACE_ placeholders are not deployable."
  }

  validation {
    condition = alltrue(flatten([
      for key, parameters in var.policy_parameter_overrides : [
        for parameter, value in parameters :
        try(
          contains(local.policies[key].parameter_names, parameter) &&
          (local.policies[key].effect_parameter == null ?
            !strcontains(lower(parameter), "effect") :
            parameter != local.policies[key].effect_parameter
          ) &&
          can(value.value),
          false
        )
      ]
    ]))
    error_message = "Use declared parameter names and { value = ... } objects; effects are controlled by the approved policy catalog."
  }

  validation {
    condition = alltrue(flatten([
      for key, policy in local.policies : [
        for parameter in keys(policy.destination_role_definition_ids) :
        try(
          can(regex("^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/[^/]+/.+", var.policy_parameter_overrides[key][parameter].value)),
          false
        )
      ]
    ]))
    error_message = "Log Analytics, private DNS zone, and private endpoint subnet parameters must contain full existing Azure resource IDs."
  }
}
