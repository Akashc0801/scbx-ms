# 
# - Generate the locals for filtering the scope against the below resource blocks and creates a map of Role Definition Ids 
#   when found in the policy definition.
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

  scope_is_management_group = length(regexall(local.regex_scope_is_management_group, var.scope)) > 0 ? true : false
  scope_is_subscription     = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_subscription, var.scope)) > 0 ? true : false : false
  scope_is_resource_group   = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_resource_group, var.scope)) > 0 ? true : false : false
  scope_is_resource         = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_resource, var.scope)) > 0 ? true : false : false

  # Validation to ensure only one reference ID approach is used
  single_reference_provided    = var.policy_definition_reference_id != null
  multiple_references_provided = length(var.policy_definition_reference_ids) > 0

  # This will cause a terraform error if both are provided
  validation_error = local.single_reference_provided && local.multiple_references_provided ? file("ERROR: Cannot specify both policy_definition_reference_id and policy_definition_reference_ids. Use only one approach.") : null

  # Handle multiple policy definition reference IDs
  reference_ids_to_process = length(var.policy_definition_reference_ids) > 0 ? var.policy_definition_reference_ids : (var.policy_definition_reference_id != null ? [var.policy_definition_reference_id] : [null])

  # Create a map of remediation names and reference IDs
  remediation_map = {
    for idx, ref_id in local.reference_ids_to_process :
    ref_id != null ? "${var.name}-${ref_id}" : var.name => {
      name         = ref_id != null ? "${var.name}-${ref_id}" : var.name
      reference_id = ref_id
    }
  }

  ################################################## For Output variable ##################################################
  azurerm_policy_remediation = concat(
    values(azurerm_management_group_policy_remediation.this),
    values(azurerm_subscription_policy_remediation.this),
    values(azurerm_resource_group_policy_remediation.this),
    values(azurerm_resource_policy_remediation.this)
  )
}