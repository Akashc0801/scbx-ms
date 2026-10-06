output "remediation_summary" {
  description = "Summary of all policy remediations created"
  value = {
    total_remediations = 5
    scopes_covered = [
      "Resource Group",
      "Subscription"
    ]
    remediation_types = [
      "Basic",
      "Advanced with Policy Reference",
      "High Throughput",
      "Conservative",
      "Subscription Level"
    ]
  }
}

output "remediation_ids" {
  description = "List of all remediation IDs"
  value = [
    module.basic_rg_remediation.remediation_id,
    module.advanced_rg_remediation.remediation_id,
    module.subscription_remediation.remediation_id,
    module.high_throughput_remediation.remediation_id,
    module.conservative_remediation.remediation_id
  ]
}

output "example_resource_group" {
  description = "Resource group details"
  value = {
    name     = azurerm_resource_group.aks_rg.name
    id       = azurerm_resource_group.aks_rg.id
    location = azurerm_resource_group.aks_rg.location
  }
}

output "policy_assignments" {
  description = "Policy assignment details"
  value = {
    kubernetes_security = {
      id   = azurerm_resource_group_policy_assignment.kubernetes_security.id
      name = azurerm_resource_group_policy_assignment.kubernetes_security.name
    }
    sql_security = {
      id   = azurerm_subscription_policy_assignment.sql_security.id
      name = azurerm_subscription_policy_assignment.sql_security.name
    }
  }
}