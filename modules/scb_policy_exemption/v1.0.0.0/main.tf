#
# - Create Policy Exemption resources
#

#
# - Create the Azure Policy Exemption at Management Group level
#
resource "azurerm_management_group_policy_exemption" "this" {
  for_each                        = local.exemptions_management_group
  name                            = lower(each.value.name)
  management_group_id             = each.value.scope
  policy_assignment_id            = var.policy_assignment_id
  policy_definition_reference_ids = each.value.reference_ids
  exemption_category              = var.exemption_category
  display_name                    = var.display_name
  description                     = var.description
  expires_on                      = var.expires_on
  metadata                        = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
}

#
# - Create the Azure Policy Exemption at Subscription level
#
resource "azurerm_subscription_policy_exemption" "this" {
  for_each                        = local.exemptions_subscription
  name                            = lower(each.value.name)
  subscription_id                 = each.value.scope
  policy_assignment_id            = var.policy_assignment_id
  policy_definition_reference_ids = each.value.reference_ids
  exemption_category              = var.exemption_category
  display_name                    = var.display_name
  description                     = var.description
  expires_on                      = var.expires_on
  metadata                        = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
}

#
# - Create the Azure Policy Exemption at Resource Group level
#
resource "azurerm_resource_group_policy_exemption" "this" {
  for_each                        = local.exemptions_resource_group
  name                            = lower(each.value.name)
  resource_group_id               = each.value.scope
  policy_assignment_id            = var.policy_assignment_id
  policy_definition_reference_ids = each.value.reference_ids
  exemption_category              = var.exemption_category
  display_name                    = var.display_name
  description                     = var.description
  expires_on                      = var.expires_on
  metadata                        = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
}

#
# - Create the Azure Policy Exemption at Resource level
#
resource "azurerm_resource_policy_exemption" "this" {
  for_each                        = local.exemptions_resource
  name                            = lower(each.value.name)
  resource_id                     = each.value.scope
  policy_assignment_id            = var.policy_assignment_id
  policy_definition_reference_ids = each.value.reference_ids
  exemption_category              = var.exemption_category
  display_name                    = var.display_name
  description                     = var.description
  expires_on                      = var.expires_on
  metadata                        = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
}
