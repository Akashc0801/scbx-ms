# SCB AI policy deployment

This root stack assigns the 57 built-in policies cataloged in
`SCB_Policies.xlsx` to management group `scb123123` through the repository's
`scb_policy_assignment` module.

The bootstrap configuration creates the Azure Storage backend once. Initialize
the root stack with Microsoft Entra ID authentication:

```powershell
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply

terraform init `
  -backend-config="resource_group_name=rg-scbx-terraform-state" `
  -backend-config="storage_account_name=stscbxtf3471ad5a" `
  -backend-config="container_name=tfstate" `
  -backend-config="key=scb-ai-policy-assignments.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform plan -out=scb-policies.tfplan
terraform apply scb-policies.tfplan
```

The backend keeps public network access enabled because GitHub-hosted runners
do not have fixed private network connectivity. Authentication uses OIDC and
Microsoft Entra RBAC; shared-key access is disabled.
