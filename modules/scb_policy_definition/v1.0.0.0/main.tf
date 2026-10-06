# Overview:
#   This module creates policy_definition
#

#
# - Generate the locals for policy definition
#
locals {
  filepath          = "${path.module}/policy_definitions/${var.policyDefinitionJsonFile}"
  policy_definition = jsondecode(file(local.filepath))
}

#
# - Create policy_definition resources
#
resource "azurerm_policy_definition" "this" {
  # Required Resource attributes
  name                = coalesce(var.name, local.policy_definition.name)
  display_name        = coalesce(var.display_name, local.policy_definition.properties.displayName)
  policy_type         = "Custom" # Possible values: [BuiltIn, Custom, NotSpecified].
  mode                = coalesce(var.mode, local.policy_definition.properties.mode)
  management_group_id = var.management_group_id

  # Optional Resource attributes
  description = var.description != null ? var.description : try(length(local.policy_definition.properties.description) > 0 ? local.policy_definition.properties.description : null)
  policy_rule = try(length(local.policy_definition.properties.policyRule) > 0 ? jsonencode(local.policy_definition.properties.policyRule) : null)
  parameters  = try(length(local.policy_definition.properties.parameters) > 0 ? jsonencode(local.policy_definition.properties.parameters) : null)
  metadata    = try(length(local.policy_definition.properties.metadata) > 0 ? jsonencode(local.policy_definition.properties.metadata) : null)
}
