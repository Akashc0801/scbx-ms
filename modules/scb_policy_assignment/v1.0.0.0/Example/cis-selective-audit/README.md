# CIS Azure Foundations v3.0.0 - Selective Audit Policy Example

This example demonstrates how to use the scb_policy_assignment module to implement selective auditing with the CIS Azure Foundations Benchmark v3.0.0 policy set.

## Overview

This configuration applies the CIS Azure Foundations Benchmark v3.0.0 policy set (containing 53 individual policies) but enables only 2 specific policies for auditing while disabling all others. This approach allows for gradual compliance implementation and testing.

## Features

- **Policy Set**: Uses the Azure built-in policy set "CIS Microsoft Azure Foundations Benchmark v3.0.0" (ID: 470a962c-86a0-433b-803a-3c176b5ce79c)
- **Selective Enablement**: Only 2 out of 53 policies are enabled for audit
- **Audit Only**: No remediation actions are taken (assign_identity = false)
- **Customizable**: Easy to modify which policies are enabled/disabled

## Enabled Policies

This example enables these 2 policies for auditing:

1. **Azure Defender for servers should be enabled** (Policy ID: 4da35fc9-c9e7-4960-aec9-797fe7d9051d)
   - Effect: AuditIfNotExists
   - Purpose: Ensures Azure Defender is enabled for server protection

2. **Key Vault keys should have an expiration date** (Policy ID: 152b15f7-8e1f-4c1f-ab71-8c010ba5dbc0)
   - Effect: Audit
   - Purpose: Ensures Key Vault keys have expiration dates for security

All other 51 CIS policies are set to "Disabled" effect.

## Prerequisites

- Azure subscription with appropriate permissions to assign policies
- Terraform with Azure provider configured
- No additional resources required (audit-only configuration)

## Usage

1. Copy the terraform.tfvars.example to terraform.tfvars
2. Update the variables with your preferred values:
   ```hcl
   policy_assignment_location = "your-azure-region"
   policy_enforcement_mode    = "Default"
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
| policy_assignment_location | Azure region for the policy assignment | string | "southeastasia" | no |
| policy_enforcement_mode | Enforcement mode for the policy | string | "Default" | no |

## Customization

To enable/disable different CIS policies:

1. Find the policy ID from the CIS Azure Foundations Benchmark v3.0.0 documentation
2. Locate the corresponding `effect-{policy-id}` parameter in main.tf
3. Change the value from "Disabled" to your desired effect (Audit, AuditIfNotExists, etc.)

Example policy effects:
- `"Audit"` - Logs non-compliance but doesn't prevent deployment
- `"AuditIfNotExists"` - Audits missing configurations
- `"Deny"` - Prevents non-compliant resource deployment
- `"Disabled"` - Policy is not evaluated

## CIS Azure Foundations Coverage

The CIS Azure Foundations Benchmark v3.0.0 covers these security areas:
- Identity and Access Management
- Azure Defender (Microsoft Defender for Cloud)
- Storage Accounts
- Database Services (SQL, PostgreSQL, CosmosDB)
- Logging and Monitoring
- Networking
- Virtual Machines
- Key Vault
- App Service

## Resources Created

- Policy assignment for CIS Azure Foundations v3.0.0 with selective audit configuration
- No managed identity (audit-only mode)
- No role assignments (no remediation required)

## Notes

- This configuration is audit-only and does not perform automatic remediation
- To enable remediation for DeployIfNotExists policies, set `assign_identity = true`
- Policy evaluation may take up to 30 minutes after assignment
- Use Azure Policy compliance dashboard to view audit results
- Consider enabling policies gradually to avoid overwhelming compliance reports

## Policy Parameter Configuration

Some CIS policies require additional parameters beyond the effect. This example includes commonly required parameters:

- **TLS Version**: Minimum TLS version for storage accounts (TLS1_2)
- **Retention Days**: Log retention period for Key Vault (365 days)
- **Network Watcher**: Resource group and locations for Network Watcher
- **SQL Auditing**: Auditing settings for SQL servers

## Compliance Monitoring

After deployment, monitor compliance through:
- Azure Policy compliance dashboard in Azure Portal
- Azure Resource Graph queries
- Azure Monitor and Log Analytics
- PowerBI compliance reports