# 
# - Generate the locals for filtering the scope against the below resource blocks.
# 
locals {
  # The following regex is designed to consistently split a resource_id into the following capture
  # groups, regardless of resource type:
  # [0] Resource scope, type substring (e.g. "/providers/Microsoft.Management/managementGroups/")
  # [1] Resource scope, name substring (e.g. "group1")
  # [2] Resource, type substring (e.g. "/providers/Microsoft.Authorization/policyAssignments/")
  # [3] Resource, name substring (e.g. "assignment1")
  regex_scope_is_management_group = "(?i)(/providers/Microsoft.Management/managementGroups/)([^/]+)$"
  regex_scope_is_subscription     = "(?i)(/subscriptions/)([^/]+)$"
  regex_scope_is_resource_group   = "(?i)(/subscriptions/[^/]+/resourceGroups/)([^/]+)$"
  regex_scope_is_resource         = "(?i)(/subscriptions/[^/]+/resourceGroups(?:/[^/]+){4}/)([^/]+)$"

  scopes_to_process = length(var.scopes) > 0 ? var.scopes : (var.scope != null ? [var.scope] : [])

  scope_details = {
    for s in local.scopes_to_process : s => {
      scope               = s
      is_management_group = length(regexall(local.regex_scope_is_management_group, s)) > 0 ? true : false
      is_subscription     = length(regexall(local.regex_scope_is_management_group, s)) > 0 ? false : length(regexall(local.regex_scope_is_subscription, s)) > 0 ? true : false
      is_resource_group   = length(regexall(local.regex_scope_is_management_group, s)) > 0 ? false : length(regexall(local.regex_scope_is_resource_group, s)) > 0 ? true : false
      is_resource         = length(regexall(local.regex_scope_is_management_group, s)) > 0 ? false : length(regexall(local.regex_scope_is_resource, s)) > 0 ? true : false
    }
  }

  # Validation to ensure only one reference ID approach is used
  single_reference_provided    = var.policy_definition_reference_id != null
  multiple_references_provided = length(var.policy_definition_reference_ids) > 0

  # This will cause a terraform error if both are provided
  validation_error = local.single_reference_provided && local.multiple_references_provided ? file("ERROR: Cannot specify both policy_definition_reference_id and policy_definition_reference_ids. Use only one approach.") : null

  # Handle multiple policy definition reference IDs
  reference_ids_to_process = length(var.policy_definition_reference_ids) > 0 ? var.policy_definition_reference_ids : (var.policy_definition_reference_id != null ? [var.policy_definition_reference_id] : [])

  # Create a map of exemption names and reference IDs list
  exemption_map = length(local.reference_ids_to_process) > 0 ? {
    for idx, ref_id in local.reference_ids_to_process :
    "${var.name}-${ref_id}" => {
      name          = "${var.name}-${ref_id}"
      reference_ids = [ref_id]
    }
    } : {
    (var.name) = {
      name          = var.name
      reference_ids = null
    }
  }

  exemptions_management_group = length(local.scope_details) > 0 ? merge([
    for s, d in local.scope_details : d.is_management_group ? {
      for ex_key, ex in local.exemption_map :
      "${s}:${ex_key}" => {
        scope         = d.scope
        name          = ex.name
        reference_ids = ex.reference_ids
      }
    } : {}
  ]...) : {}

  exemptions_subscription = length(local.scope_details) > 0 ? merge([
    for s, d in local.scope_details : d.is_subscription ? {
      for ex_key, ex in local.exemption_map :
      "${s}:${ex_key}" => {
        scope         = d.scope
        name          = ex.name
        reference_ids = ex.reference_ids
      }
    } : {}
  ]...) : {}

  exemptions_resource_group = length(local.scope_details) > 0 ? merge([
    for s, d in local.scope_details : d.is_resource_group ? {
      for ex_key, ex in local.exemption_map :
      "${s}:${ex_key}" => {
        scope         = d.scope
        name          = ex.name
        reference_ids = ex.reference_ids
      }
    } : {}
  ]...) : {}

  exemptions_resource = length(local.scope_details) > 0 ? merge([
    for s, d in local.scope_details : d.is_resource ? {
      for ex_key, ex in local.exemption_map :
      "${s}:${ex_key}" => {
        scope         = d.scope
        name          = ex.name
        reference_ids = ex.reference_ids
      }
    } : {}
  ]...) : {}

  ################################################## For Output variable ##################################################
  azurerm_policy_exemption = concat(
    values(azurerm_management_group_policy_exemption.this),
    values(azurerm_subscription_policy_exemption.this),
    values(azurerm_resource_group_policy_exemption.this),
    values(azurerm_resource_policy_exemption.this)
  )
}
