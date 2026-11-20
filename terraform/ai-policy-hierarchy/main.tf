locals {
  policies = {
    for policy in jsondecode(file("${path.module}/policies.json")) :
    policy.assignment_key => policy
  }

  management_group_scopes = {
    for target, id in var.management_group_ids :
    target => "/providers/Microsoft.Management/managementGroups/${id}"
  }

  policy_parameters = {
    for key, policy in local.policies : key => merge(
      policy.default_parameters,
      lookup(var.policy_parameter_overrides, key, {}),
      policy.effect_parameter == null ? {} : {
        (policy.effect_parameter) = { value = policy.effect }
      }
    )
  }

  destination_roles = {
    for grant in flatten([
      for key, policy in local.policies : [
        for parameter, role_id in policy.destination_role_definition_ids : {
          key        = "${key}-${parameter}"
          assignment = key
          parameter  = parameter
          role_id    = role_id
          scope      = local.policy_parameters[key][parameter].value
        }
      ]
      if contains(["DeployIfNotExists", "Modify"], policy.effect)
    ]) : grant.key => grant
  }
}

module "policy_assignment" {
  source   = "../../modules/scb_policy_assignment/v1.0.0.0"
  for_each = local.policies

  name                 = "scb-ai-${substr(sha256(each.key), 0, 17)}"
  display_name         = substr(each.value.display_name, 0, 128)
  description          = "Policy-BuiltIN-AI.xlsx row ${each.value.workbook_row}: ${each.value.control_group}."
  policy_definition_id = each.value.definition_id
  scope                = local.management_group_scopes[each.value.target]
  enforcement_mode     = "Default"
  location             = var.assignment_location
  assign_identity      = contains(["DeployIfNotExists", "Modify"], each.value.effect)
  parameters           = local.policy_parameters[each.key]

  # Initiatives cannot extract child roles automatically in the existing module.
  manual_role_definition_ids       = each.value.role_definition_ids
  enable_role_assignment_telemetry = false

  metadata = {
    source          = "Policy-BuiltIN-AI.xlsx"
    workbookRow     = each.value.workbook_row
    requestedEffect = each.value.requested_effect
    target          = each.value.target
    managedBy       = "Terraform"
  }
}

module "destination_role_assignments" {
  source = "../../modules/scb_role_assignments/v1.0.0.0"

  enable_telemetry = false
  role_assignments_azure_resource_manager = {
    for key, grant in local.destination_roles : key => {
      principal_id                     = module.policy_assignment[grant.assignment].principal_id
      principal_type                   = "ServicePrincipal"
      role_definition_id               = grant.role_id
      scope                            = grant.scope
      skip_service_principal_aad_check = true
      description                      = "Policy ${grant.assignment}: access to ${grant.parameter}."
    }
  }
}
