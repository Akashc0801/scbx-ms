output "policy_assignment_ids" {
  description = "Policy assignment resource IDs keyed by policy definition ID."
  value = {
    for definition_id, assignment in module.ai_landing_zone_policy_assignment :
    definition_id => assignment.id
  }
}

output "policy_assignment_principal_ids" {
  description = "Managed identity principal IDs for enabled DeployIfNotExists and Modify assignments."
  value = {
    for definition_id, assignment in module.ai_landing_zone_policy_assignment :
    definition_id => assignment.principal_id
    if assignment.principal_id != null
  }
}

output "disabled_policy_definition_ids" {
  description = "Policies disabled because they require environment-specific parameters or have no declared default effect."
  value = [
    for definition_id, policy in local.policies :
    definition_id if policy.effective_effect == "Disabled"
  ]
}
