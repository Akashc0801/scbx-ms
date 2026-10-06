# Policy Assignment Module Examples

This directory contains practical examples demonstrating different use cases for the scb_policy_assignment module.

## Available Examples

### 1. Key Vault Audit Logging (`keyvault-audit-logging/`)

Demonstrates how to configure audit logging for Azure Key Vault resources using a built-in Azure policy set.

**Use Case**: Ensure all Key Vault resources in your subscription send diagnostic logs to a Log Analytics workspace for security monitoring and compliance.

**Key Features**:
- Uses Azure built-in policy set for Key Vault diagnostic settings
- Automatic remediation with system-assigned managed identity
- Configurable Log Analytics workspace target
- DeployIfNotExists effect for automatic configuration

**Ideal For**: Organizations needing to meet security logging requirements for Key Vault resources.

### 2. CIS Selective Audit (`cis-selective-audit/`)

Shows how to implement selective auditing with the CIS Azure Foundations Benchmark v3.0.0 policy set.

**Use Case**: Gradually implement CIS compliance by enabling only specific policies for audit while keeping others disabled.

**Key Features**:
- CIS Azure Foundations Benchmark v3.0.0 (53 policies total)
- Only 2 policies enabled for demonstration
- Audit-only mode (no automatic remediation)
- Easy customization for enabling/disabling specific policies

**Ideal For**: Organizations starting their compliance journey or testing CIS policy impacts before full implementation.

## Getting Started

1. Choose the example that matches your use case
2. Navigate to the example directory
3. Follow the README.md instructions in each example
4. Copy terraform.tfvars.example to terraform.tfvars
5. Customize variables for your environment
6. Run terraform init, plan, and apply

## Example Structure

Each example contains:
- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `terraform.tfvars.example` - Example variable values
- `README.md` - Detailed documentation and usage instructions

## Common Prerequisites

- Azure subscription with appropriate permissions for policy assignments
- Terraform installed and configured
- Azure CLI authenticated (or other Azure authentication method)
- Understanding of Azure Policy concepts and effects

## Policy Effects Explained

- **Audit**: Logs compliance state but allows all deployments
- **AuditIfNotExists**: Audits when a related resource doesn't exist
- **Deny**: Prevents non-compliant resource deployments
- **DeployIfNotExists**: Automatically creates compliant configurations
- **Disabled**: Policy is not evaluated

## Best Practices

1. **Start with Audit**: Begin with audit-only mode to understand compliance impact
2. **Gradual Implementation**: Enable policies incrementally to avoid disruption
3. **Test First**: Use separate subscriptions or resource groups for testing
4. **Monitor Compliance**: Regularly review Azure Policy compliance dashboard
5. **Document Exceptions**: Use policy exemptions for legitimate non-compliance cases

## Support

For questions about these examples or the scb_policy_assignment module:
1. Review the main module documentation
2. Check Azure Policy documentation for built-in policies
3. Consult CIS Azure Foundations Benchmark documentation for compliance details