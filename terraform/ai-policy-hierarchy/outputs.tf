output "policy_role_report" {
  description = "Applied assignment IDs, identities, effects, and management-group/destination role grants for every workbook row."
  value = {
    for key, policy in local.policies : key => {
      workbook_row           = policy.workbook_row
      policy                 = policy.display_name
      definition_id          = policy.definition_id
      requested_effect       = policy.requested_effect
      assigned_effect        = policy.effect
      scope                  = local.management_group_scopes[policy.target]
      assignment_id          = module.policy_assignment[key].id
      principal_id           = module.policy_assignment[key].principal_id
      management_group_roles = module.policy_assignment[key].identity_role_assignments
      destination_roles = {
        for grant_key, grant in module.destination_role_assignments.azure_resource_manager_role_assignments :
        grant_key => grant
        if local.destination_roles[grant_key].assignment == key
      }
    }
  }
}
