#
# Copyright 2023 BBL & Microsoft. All rights reserved.
#

output "id" {
  description = "The ID for the Policy Definition."
  value       = azurerm_policy_definition.this.id
}
