
#   - Creates policy remediation for the policy assignments associated with policy definition and policy set definitions at various scopes
#   - Supports single or multiple policy definition reference IDs within policy sets

#
# - Create Policy Remediation resources
# - Create the Azure Policy Remediation on Management Group level
#
resource "azurerm_management_group_policy_remediation" "this" {
  for_each                       = local.scope_is_management_group == true ? local.remediation_map : {}
  name                           = lower(each.value.name)
  management_group_id            = var.scope
  policy_assignment_id           = var.policy_assignment_id
  policy_definition_reference_id = each.value.reference_id
  location_filters               = var.location_filters
  failure_percentage             = var.failure_percentage
  parallel_deployments           = var.parallel_deployments
  resource_count                 = var.resource_count
}

# 
# - Create the Azure Policy Remediation on Subscription level
#
resource "azurerm_subscription_policy_remediation" "this" {
  for_each                       = local.scope_is_subscription == true ? local.remediation_map : {}
  name                           = lower(each.value.name)
  subscription_id                = var.scope
  policy_assignment_id           = var.policy_assignment_id
  policy_definition_reference_id = each.value.reference_id
  location_filters               = var.location_filters
  resource_discovery_mode        = var.resource_discovery_mode
  failure_percentage             = var.failure_percentage
  parallel_deployments           = var.parallel_deployments
  resource_count                 = var.resource_count
}

# 
# - Create the Azure Policy Remediation on Resource Group level
#
resource "azurerm_resource_group_policy_remediation" "this" {
  for_each                       = local.scope_is_resource_group == true ? local.remediation_map : {}
  name                           = lower(each.value.name)
  resource_group_id              = var.scope
  policy_assignment_id           = var.policy_assignment_id
  policy_definition_reference_id = each.value.reference_id
  location_filters               = var.location_filters
  resource_discovery_mode        = var.resource_discovery_mode
  failure_percentage             = var.failure_percentage
  parallel_deployments           = var.parallel_deployments
  resource_count                 = var.resource_count
}

# 
# - Create the Azure Policy Remediation on Resource level
#
resource "azurerm_resource_policy_remediation" "this" {
  for_each                       = local.scope_is_resource == true ? local.remediation_map : {}
  name                           = lower(each.value.name)
  resource_id                    = var.scope
  policy_assignment_id           = var.policy_assignment_id
  policy_definition_reference_id = each.value.reference_id
  location_filters               = var.location_filters
  resource_discovery_mode        = var.resource_discovery_mode
  failure_percentage             = var.failure_percentage
  parallel_deployments           = var.parallel_deployments
  resource_count                 = var.resource_count
}
