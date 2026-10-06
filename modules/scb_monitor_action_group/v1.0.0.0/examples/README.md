# Azure Monitor Action Group Examples

This directory contains examples demonstrating various usage patterns for the Azure Monitor Action Group module.

## Examples

### [Basic Email Notifications](./basic-email.md)
Simple action group with email receivers for standard notifications.

**Use Cases:**
- Team notifications
- Informational alerts
- Non-critical monitoring

### [Multi-Channel Alerts](./multi-channel.md)
Action group using multiple notification channels (email, SMS, voice, webhook) for tiered alerting.

**Use Cases:**
- Production environments
- Critical applications
- On-call escalation
- Multi-team notifications

### [Webhook Integration](./webhook-integration.md)
Various webhook configurations including Azure AD authentication for secure integrations.

**Use Cases:**
- SIEM integration
- Custom ticketing systems
- External monitoring platforms
- Secure API endpoints

### [Complete Example](./complete-example.md)
Comprehensive setup demonstrating all receiver types and advanced configurations.

**Use Cases:**
- Enterprise monitoring
- Complex notification workflows
- Automated remediation
- Multi-system integration

## Quick Start

1. Choose the example that matches your use case
2. Copy the relevant code to your Terraform configuration
3. Update the values (resource names, email addresses, phone numbers, etc.)
4. Run `terraform init` and `terraform apply`
5. Test the action group using Azure Portal's "Test action group" feature

## Common Patterns

### Pattern 1: Severity-Based Routing
Create separate action groups for different severity levels:
- **Info/Warning**: Email only
- **Error**: Email + SMS
- **Critical**: Email + SMS + Voice + Automation

### Pattern 2: Team-Based Routing
Create action groups per team or application:
- **App Team**: Email to app-team@example.com
- **Platform Team**: Email to platform-team@example.com
- **Security Team**: Email + SMS for security alerts

### Pattern 3: Time-Based Routing
Use multiple action groups with scheduled logic apps:
- **Business Hours**: Email notifications
- **After Hours**: SMS + Voice to on-call engineer

### Pattern 4: Integration Hub
Single action group as central hub:
- Webhook to central processor
- Logic App routes to appropriate teams
- Event Hub for analytics
- Automation for remediation

## Receiver Selection Guide

| Receiver Type | Speed | Cost | Use Case |
|--------------|-------|------|----------|
| Email | Medium | Free | General notifications |
| SMS | Fast | Paid | Urgent alerts |
| Voice | Fast | Paid | Critical alerts |
| Webhook | Fast | Free | System integration |
| Azure Function | Fast | Compute cost | Custom processing |
| Logic App | Medium | Per-execution | Workflow automation |
| Automation Runbook | Medium | Compute cost | Remediation tasks |
| Event Hub | Fast | Event Hub cost | Stream processing |
| ARM Role | Medium | Free | Role-based notifications |
| ITSM | Medium | Service cost | Ticket creation |
| Azure App Push | Fast | Free | Mobile notifications |

## Testing Recommendations

1. **Start with Email**: Test basic functionality with email receivers first
2. **Add Webhooks**: Implement webhook integration before production
3. **Test SMS Carefully**: SMS costs money - test sparingly
4. **Validate Voice**: Voice calls are expensive - test only when necessary
5. **Use Test Mode**: Azure Portal has built-in action group testing

## Additional Resources

- [Azure Monitor Action Groups Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups)
- [Common Alert Schema](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-common-schema)
- [Alert Processing Rules](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-processing-rules)
- [Action Group Best Practices](https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-alerts)
