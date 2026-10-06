# Overview:
#   This module:
#   - Creates policy-set-definition and associated resources,

# 
# - Generate the locals
# 
locals {
  filepath              = "${path.module}/policy_set_definitions/${var.policySetDefinitionJsonFile}"
  policy_set_definition = jsondecode(file(local.filepath))
}

#
# - Create policy-set-definition resources
#

resource "azurerm_policy_set_definition" "this" {
  # Mandatory resource attributes
  name         = coalesce(var.name, local.policy_set_definition.name)
  display_name = coalesce(var.display_name, local.policy_set_definition.properties.displayName)
  policy_type  = "Custom"

  dynamic "policy_definition_reference" {
    for_each = [
      for item in local.policy_set_definition.properties.policyDefinitions :
      {
        policyDefinitionId          = item.policyDefinitionId
        parameters                  = try(jsonencode(item.parameters), null)
        policyDefinitionReferenceId = try(item.policyDefinitionReferenceId, null)
        groupNames                  = try(item.groupNames, null)
      }
    ]
    content {
      policy_definition_id = policy_definition_reference.value["policyDefinitionId"]
      parameter_values     = policy_definition_reference.value["parameters"]
      reference_id         = policy_definition_reference.value["policyDefinitionReferenceId"]
      policy_group_names   = policy_definition_reference.value["groupNames"]
    }
  }

  dynamic "policy_definition_group" {
    for_each = coalesce(lookup(local.policy_set_definition.properties, "policyDefinitionGroups", null), [])
    content {
      name                            = policy_definition_group.value.name
      display_name                    = try(policy_definition_group.value.displayName, null)
      category                        = try(policy_definition_group.value.category, null)
      description                     = try(policy_definition_group.value.description, null)
      additional_metadata_resource_id = try(policy_definition_group.value.additionalMetadataId, null)
    }
  }

  # Optional Resource attributes
  description         = can(local.policy_set_definition.properties.description) && length(local.policy_set_definition.properties.description) > 0 ? jsonencode(local.policy_set_definition.properties.description) : null
  parameters          = can(local.policy_set_definition.properties.parameters) && length(local.policy_set_definition.properties.parameters) > 0 ? jsonencode(local.policy_set_definition.properties.parameters) : null
  metadata            = can(local.policy_set_definition.properties.metadata) && length(local.policy_set_definition.properties.metadata) > 0 ? jsonencode(local.policy_set_definition.properties.metadata) : null
  management_group_id = var.management_group_id
}