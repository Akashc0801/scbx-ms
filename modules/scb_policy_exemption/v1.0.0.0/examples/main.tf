# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Data source for current subscription
data "azurerm_client_config" "current" {}

# Example Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Purpose     = "PolicyExemptionDemo"
  }
}

# Example Policy Assignment (simplified)
resource "azurerm_resource_group_policy_assignment" "example" {
  name                 = "example-policy-assignment"
  resource_group_id    = azurerm_resource_group.example.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5ffd78d7-1d8c-4c77-9d8a-3d5db5f79963" # Allowed locations

  display_name = "Allowed locations"
  description  = "Example assignment used for policy exemption demo"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["eastus", "westus2"]
    }
  })
}

# Example Policy Exemption using scb_policy_exemption module
module "example_policy_exemption" {
  source = "../"

  name                 = "exempt-example"
  scope                = azurerm_resource_group.example.id
  policy_assignment_id = azurerm_resource_group_policy_assignment.example.id
  exemption_category   = "Waiver"
  display_name         = "Example exemption"
  description          = "Temporary waiver for a specific workload"
  expires_on           = "2026-12-31T23:59:59Z"

  metadata = {
    approvedBy = "security-team"
    ticketId   = "INC123456"
  }
}

output "exemption_details" {
  description = "Details of the created policy exemption"
  value = {
    id   = module.example_policy_exemption.exemption_id
    name = module.example_policy_exemption.exemption_name
  }
}
