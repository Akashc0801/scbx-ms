locals {
  management_group_scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  policies = {
    for policy in jsondecode(file("${path.module}/../modules/scb_policy_assignment/v1.0.0.0/Example/ai-landing-zone-policies/policies.json")) :
    policy.definition_id => policy
  }

  required_parameter_defaults = {
    "/providers/Microsoft.Authorization/policyDefinitions/595f98a5-b562-4ab6-b9c8-2ff9f39a3f7c" = {
      entityKind = { value = [] }
      filterName = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/9224c1cc-34fc-44f1-ad08-5c4b079c9ce6" = {
      entityKind = { value = [] }
      filterName = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/af253d37-136a-42f8-a1fc-30010c083d41" = {
      filterName = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/930f48f9-f07e-427c-9494-52603581c6a9" = {
      filterName = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/f3a9c2e0-7b4d-4d8f-9c3a-2e1f6b9a8d4e" = {
      filterName = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/db630ad5-52e9-4f4d-9c44-53912fe40053" = {
      privateEndpointSubnetId = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/b698b005-b660-4837-b833-a7aaab26ddba" = {
      privateEndpointSubnetId = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/ee40564d-486e-4f68-a5ca-7a621edae0fb" = {
      privateDnsZoneId = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/7838fd83-5cbb-4b5d-888c-bfa240972597" = {
      privateEndpointSubnetId = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/f59276f0-5740-4aaf-821d-45d185aa210e" = {
      logAnalytics = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/3d5da587-71bd-41f5-ac95-dd3330c2d58d" = {
      eventHubRuleId = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/08ba64b8-738f-4918-9686-730d2ed79c7d" = {
      logAnalytics = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/0628b917-d4b4-4af5-bc2b-b4f87cd173ab" = {
      eventHubAuthorizationRuleId = { value = "" }
      resourceLocation            = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/55d1f543-d1b0-4811-9663-d6d0dbc6326d" = {
      logAnalytics = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/14e81583-c89c-47db-af0d-f9ddddcccd9f" = {
      resourceLocation = { value = "" }
      storageAccount   = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/971199b6-1971-4d3e-85b0-fa7639044679" = {
      eventHubAuthorizationRuleId = { value = "" }
      resourceLocation            = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/8def4bdd-4362-4ed6-a26f-7bf8f2c58839" = {
      logAnalytics = { value = "" }
    }
    "/providers/Microsoft.Authorization/policyDefinitions/480ee186-7504-48ac-b64e-af38673aa2c6" = {
      resourceLocation = { value = "" }
      storageAccount   = { value = "" }
    }
  }

  policy_parameters = {
    for definition_id, policy in local.policies :
    definition_id => merge(
      {
        effect = {
          value = policy.effective_effect
        }
      },
      lookup(local.required_parameter_defaults, definition_id, {}),
      lookup(var.policy_parameter_overrides, definition_id, {})
    )
  }
}

module "ai_landing_zone_policy_assignment" {
  source   = "../modules/scb_policy_assignment/v1.0.0.0"
  for_each = local.policies

  name                 = "scb-ai-${substr(basename(each.key), 0, 8)}"
  display_name         = substr(each.value.display_name, 0, 128)
  description          = "SCB AI landing zone policy assignment sourced from SCB_Policies.xlsx."
  policy_definition_id = each.key
  scope                = local.management_group_scope
  enforcement_mode     = "Default"
  location             = var.assignment_location
  assign_identity      = contains(["DeployIfNotExists", "Modify"], each.value.effective_effect)
  parameters           = local.policy_parameters[each.key]

  metadata = {
    source     = "SCB_Policies.xlsx"
    managedBy  = "Terraform"
    repository = "Akashc0801/scbx-ms"
  }
}
