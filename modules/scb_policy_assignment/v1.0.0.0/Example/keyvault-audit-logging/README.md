# Key Vault Audit Logging Policy Example

This example demonstrates how to use the scb_policy_assignment module to implement audit logging for Azure Key Vault resources.

## Overview

This configuration applies the "Configure Azure Key Vault to route diagnostic logs to Log Analytics workspace" policy set to your Azure subscription. It automatically configures diagnostic settings for all Key Vault resources to send logs to a specified Log Analytics workspace.

## Features

- **Policy Set**: Uses the Azure built-in policy set "Configure Azure Key Vault to route diagnostic logs to Log Analytics workspace" (ID: f5b29bc4-feca-4cc6-a58a-772dd5e290a5)
- **Enforcement Mode**: Configurable enforcement (Default or DoNotEnforce)
- **Automatic Remediation**: Uses DeployIfNotExists effect with system-assigned managed identity
- **Resource Filtering**: Targets only Key Vault resources with configurable location filtering

## Prerequisites

- Azure subscription with appropriate permissions to assign policies
- Existing Log Analytics workspace
- Terraform with Azure provider configured

## Usage

1. Copy the terraform.tfvars.example to terraform.tfvars
2. Update the variables with your actual values:
   ```hcl
   log_analytics_workspace_name = "your-log-analytics-workspace"
   log_analytics_resource_group = "your-resource-group"
   policy_assignment_location   = "your-azure-region"
   ```
3. Run Terraform commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| log_analytics_workspace_name | Name of the Log Analytics workspace | string | n/a | yes |
| log_analytics_resource_group | Resource group containing the Log Analytics workspace | string | n/a | yes |
| policy_assignment_location | Azure region for the policy assignment | string | n/a | yes |
| policy_enforcement_mode | Enforcement mode for the policy | string | "Default" | no |
| policy_effect | Effect of the policy | string | "DeployIfNotExists" | no |
| diagnostic_setting_name | Name for the diagnostic setting | string | "setByPolicy-LogAnalytics" | no |
| resource_location_list | List of allowed resource locations | list(string) | ["*"] | no |

## Resources Created

- Policy assignment for Key Vault diagnostic settings
- System-assigned managed identity for automatic remediation
- Role assignment for the managed identity (Log Analytics Contributor role)

## Policy Details

This policy set ensures that:
- All Key Vault resources have diagnostic settings configured
- Logs are sent to the specified Log Analytics workspace
- Diagnostic settings are automatically created for new Key Vault resources
- Non-compliant resources are automatically remediated (when enforcement is enabled)

## Notes

- The policy uses a system-assigned managed identity for automatic remediation
- The managed identity is automatically assigned the necessary permissions
- The policy only affects Key Vault resources, other resource types are ignored
- Location filtering can be customized to target specific Azure regions