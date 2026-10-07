# Azure Deployment Plan

## Status

Validated

## Objective

Deploy the SCB AI landing-zone Azure Policy assignments to management group
`scb123123` using the repository's Terraform policy-assignment module.

## Planned Artifacts

- `terraform/bootstrap/` documents the dedicated Azure Storage state backend,
  which was provisioned manually through Azure Cloud Shell.
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
- Plan and apply use the federated credential restricted to the `main` branch.

## Deployment Safety

- Run Terraform formatting and validation.
- Bootstrap the remote-state resources before initializing the root stack.
- Run a Terraform plan and inspect destructive or replacement actions.
- Require explicit confirmation before Terraform apply.
- Verify all expected policy assignments after apply.

## Validation Checklist

- [x] All validation checks pass
  - [x] Terraform is installed.
  - [x] Azure CLI is installed and authenticated to the confirmed subscription.
  - [x] Terraform initialization succeeds.
  - [x] Terraform formatting check succeeds.
  - [x] Terraform validation succeeds.
  - [x] Terraform plan succeeds.
  - [x] Terraform state is accessible.
  - [x] No unresolved Go-style environment templates exist.
  - [x] Terraform variable JSON syntax is valid when applicable.
  - [x] Existing Azure Policy assignments do not conflict with the deployment.
  - [x] Static RBAC review confirms least-privilege role assignments.

## Role Assignment Verification

- Status: Verified
- Deployment identity:
  `ad3ac83f-7b06-49db-b6dd-429ea44e5f87`
- Subscription roles: `Contributor`, `User Access Administrator`
- Management-group roles: `Resource Policy Contributor`,
  `User Access Administrator`
- State role: `Storage Blob Data Contributor`
- Planned remediation assignments: 12, scoped by the policy-assignment module.

## Section 7: Validation Proof

- GitHub Actions run:
  `https://github.com/Akashc0801/scbx-ms/actions/runs/37580670505`
- OIDC authentication: Passed
- Azure subscription and tenant context: Passed
- Existing remote-state container access: Passed
- `terraform fmt -check -recursive`: Passed
- `terraform init` with Azure Storage backend: Passed
- `terraform validate`: Passed
- `terraform plan`: Passed
- Plan result: 85 additions, 0 changes, 0 destroys
  - 57 management-group policy assignments
  - 12 remediation role assignments
  - 8 module telemetry resources
  - 8 UUID resources
