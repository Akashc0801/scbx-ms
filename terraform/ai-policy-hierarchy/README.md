# AI management-group policy assignments

Independent Terraform root generated from `Policy-BuiltIN-AI.xlsx` and verified
against Azure built-in definitions. Uses the existing `scb_policy_assignment`
and `scb_role_assignments` modules. The existing parent Terraform stack is
unchanged; this folder has its own state.

## Scope and effects

| Workbook target | Existing management-group input | Assignments |
| --- | --- | ---: |
| Both | `management_group_ids.ai_nonprod` | 37 |
| AI Gateway LZ | `management_group_ids.ai_gateway` | 21 |
| AI Agent LZ | `management_group_ids.ai_agent` | 29 |

Root -> Financial -> Non-Prod -> AI Non-Prod -> { AI GW, Agent }.
Ancestor assignments remain inherited and are neither recreated nor managed
here. Management groups are not created or moved. Verify this existing hierarchy
before deployment: Terraform inputs alone cannot establish inheritance.

All 87 rows are preserved, including definitions assigned separately to each
child group. Assignment keys include the target and full definition GUID;
Azure assignment names are deterministic hashes capped at 24 characters.

Three corrections were approved because the workbook effects are unsupported:

| Row | Definition GUID | Workbook | Assigned |
| --- | --- | --- | --- |
| 26 | `0fc55270-f8bf-4feb-b7b8-5e7e7eacc6a6` | Audit | AuditIfNotExists |
| 50 | `df73bd95-24da-4a4f-96b9-4e8b94b402bd` | Deny | AuditIfNotExists |
| 51 | `7ca8c8ac-3a6e-493d-99ba-c5fa35347ff2` | Modify | DeployIfNotExists |

The Microsoft cloud security benchmark is assigned with its verified built-in
defaults: audit/audit-if-not-exists or disabled child effects, with no enabled
Deny/Modify/DeployIfNotExists children. It has no single `effect` parameter.
No remediation identity or roles are granted for this audit baseline. Review
future built-in revisions before planning; the catalog reflects definitions
verified on 2026-11-20, not an immutable Azure definition version.

## Logging overlap

As approved, both logging initiatives and every standalone logging child are
assigned. The allLogs initiative and standalone children share the setting name
`scb-ai-allLogs` and category `allLogs`, so overlapping children converge on
the same setting. The audit initiative uses the separate name `scb-ai-audit`.
Keep the same workspace and compatible optional parameters for overlapping
allLogs assignments. Custom overrides must not give these assignments
conflicting destinations, setting names, categories, or location filters.

**Audit categories are also contained in allLogs.** Keeping both initiatives
can duplicate ingestion and incur additional Log Analytics costs. Review
existing diagnostic settings and the per-resource settings limit before apply.
The workbook's "where audit-only categories are sufficient" condition requires
your optional `resourceTypeList` override on the audit initiative; its default
targets all supported audit resource types.

## Identities, roles and documentation

Only effective `DeployIfNotExists` and `Modify` assignments receive a
system-assigned identity. Individual policy roles are extracted by the existing
module from `then.details.roleDefinitionIds`. Verified roles are also passed
explicitly, particularly for initiatives because the existing module does not
extract their child roles. Duplicate role IDs are consolidated by that module.
No blanket Owner or User Access Administrator grant is made.

See [POLICY-ROLES.csv](POLICY-ROLES.csv) for every row, assignment key, effect,
identity requirement, role name/GUID, scope input, and required parameter.
[policies.json](policies.json) is the machine-readable assignment catalog.
Where a definition itself requires Contributor, that broad built-in requirement
is preserved and explicitly listed rather than silently substituted.

The definition's remediation roles apply at its target management group,
inheriting to resources below it. Additionally, the same policy identity gets:

| Parameter destination | Role | Grant scope |
| --- | --- | --- |
| `logAnalytics` | Log Analytics Contributor | Exact workspace resource ID |
| `privateEndpointSubnetId` | Network Contributor | Exact subnet resource ID |
| `privateDnsZoneId` / `privateDnsZoneId1` ... `5` | Network Contributor | Exact private DNS zone resource ID |

These destination grants support shared resources outside the target hierarchy.
Network Contributor includes subnet join and private DNS zone operations
without granting a policy's service-specific roles on networking destinations.
They are documented even when a destination already inherits sufficient
management-group permissions. New principal grants use the service-principal
type and skip the Entra replication check.

After apply, `policy_role_report` records actual assignment IDs, principal IDs,
role assignment IDs, role definition IDs, and exact scopes. Existing legacy
module outputs are preserved; new detailed outputs report the created ARM grants.
Role-module telemetry is disabled for this stack.

## Configure and validate

```powershell
Set-Location terraform\ai-policy-hierarchy
Copy-Item terraform.tfvars.example terraform.tfvars
# Replace subscription/MG placeholders and every required parameter value.
terraform init
terraform validate
terraform test
terraform plan -out=ai-policy-hierarchy.tfplan
# Only after reviewing and approving the plan:
terraform apply ai-policy-hierarchy.tfplan
terraform output -json policy_role_report | Set-Content -Encoding utf8 policy-role-report.json
```

The supplied example deliberately contains nondeployable placeholders.
Missing/empty required parameters, placeholder strings/arrays, unknown
assignment keys, unsupported parameter names, and effect overrides block
planning. Baseline initiative effect parameters are also reserved to preserve
its audit-only behavior. Use real workspace, subnet and DNS IDs; audit content-filter policies
also need approved `filterName` and `entityKind` values. Optional settings use
Azure's actual definition defaults, not invented neutral values.

The existing ancestor effects still apply: a child assignment cannot weaken an
inherited Deny. Assess existing assignments/exemptions to avoid duplication
with other Terraform states. Import already-existing assignments rather than
attempting to recreate them.

This root uses local state by default and does not reuse the parent's backend.
Configure your approved remote backend with a **distinct state key** before
production deployment. The deployment principal needs policy assignment write
access at all three management groups, role-assignment write access there and
at destination scopes, and read access to built-in definitions.

The test suite uses only mocked providers; it creates no Azure resources.
Assignment/RBAC apply does not automatically remediate existing resources.
Create separately reviewed remediation tasks (using the existing
`scb_policy_remediation` module if needed), and use each child reference ID for
initiative remediation. Vulnerability remediation SLAs remain operational
controls outside Azure Policy, as specified in the workbook.
