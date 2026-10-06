# Basic Email Notifications Example

This example shows how to create a simple Action Group with email notifications.

## Usage

```hcl
provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-action-group-example"
  location = "East US"
}

# Create Action Group with email receivers
module "email_action_group" {
  source = "../../"

  name                = "ag-email-notifications"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "emailalert"

  email_receivers = [
    {
      name                    = "Admin Team"
      email_address           = "admin@example.com"
      use_common_alert_schema = true
    },
    {
      name                    = "DevOps Team"
      email_address           = "devops@example.com"
      use_common_alert_schema = true
    }
  ]

  tags = {
    Environment = "Development"
    Purpose     = "Testing"
  }
}

# Output the Action Group ID for use in alert rules
output "action_group_id" {
  description = "The ID of the Action Group"
  value       = module.email_action_group.id
}
```

## Notes

- Email addresses must be valid and accessible
- Recipients will receive a confirmation email when first added
- Common Alert Schema is recommended for consistent notification format
