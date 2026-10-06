# Azure Deployment Plan

## Status

Ready for Validation

## Objective

Deploy the SCB AI landing-zone Azure Policy assignments to management group
`scb123123` using the repository's Terraform policy-assignment module.

## Planned Artifacts

- `terraform/bootstrap/` creates a dedicated Azure Storage state backend.
- `terraform/` calls the existing `scb_policy_assignment` module for all 57
  policies cataloged from `SCB_Policies.xlsx`.
- `.github/workflows/azure-deploy.yml` uses GitHub OIDC, runs formatting and
  validation, produces plans, and permits apply only through an explicit
  manual workflow action.
- Deployment and validation evidence are recorded before completion.

## Azure Context

- Subscription: `scbx-testing` (`3471ad5a-d8a8-4a80-b30b-668798733c14`)
- Tenant: `Default Directory` (`7b180d87-6e3e-4bc3-9372-0ab40c6997bb`)
- Management group: `scb123123`
- Assignment identity location: `southeastasia`

## Recipe

Pure Terraform is used because the user explicitly requested a Terraform
folder and GitHub Actions workflow for an existing module repository.

## Remote State

- Resource group: `rg-scbx-terraform-state`
- Storage account: `stscbxtf3471ad5a`
- Blob container: `tfstate`
- State key: `scb-ai-policy-assignments.tfstate`
- Authentication: Microsoft Entra ID / OIDC; no storage access keys

## Policy Behavior

- 57 built-in policy definitions are assigned at management group scope.
- 38 assignments retain the workbook default effect.
- 18 policies requiring environment-specific resource IDs remain disabled.
- One preview policy without a declared default effect remains disabled.
- Enabled `DeployIfNotExists` and `Modify` policies receive managed identities.
- Enforcement mode is `Default`.

## Workflow

- Pull requests execute formatting and static Terraform validation without
  Azure authentication.
- Pushes to `main` and manual `plan` runs authenticate with OIDC and execute a
  remote-state Terraform plan.
- Apply is available only through `workflow_dispatch` with `action=apply`.
- GitHub secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`. The non-secret
  subscription ID is pinned in the workflow and Terraform configuration.
- The workflow targets the `azure-policy-production` GitHub environment so
  repository owners can configure required reviewers.

## Deployment Safety

- Run Terraform formatting and validation.
- Bootstrap the remote-state resources before initializing the root stack.
- Run a Terraform plan and inspect destructive or replacement actions.
- Require explicit confirmation before Terraform apply.
- Verify all expected policy assignments after apply.

## Validation Checklist

- [ ] All validation checks pass
  - [ ] Terraform is installed.
  - [ ] Azure CLI is installed and authenticated to the confirmed subscription.
  - [ ] Terraform initialization succeeds.
  - [ ] Terraform formatting check succeeds.
  - [ ] Terraform validation succeeds.
  - [ ] Terraform plan succeeds.
  - [ ] Terraform state is accessible.
  - [ ] No unresolved Go-style environment templates exist.
  - [ ] Terraform variable JSON syntax is valid when applicable.
  - [ ] Existing Azure Policy assignments do not conflict with the deployment.
  - [ ] Static RBAC review confirms least-privilege role assignments.
