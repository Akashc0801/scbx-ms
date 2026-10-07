# AI landing zone policy assignments

This example assigns all 57 built-in Azure Policy definitions cataloged in
`SCB_Policies.xlsx` to management group `scb123123` by calling the
`scb_policy_assignment` module once per definition.

Policies use the default effect recorded in the workbook and enforcement mode
`Default`. Policies with mandatory environment-specific parameters are assigned
with the `Disabled` effect and neutral, type-correct parameter values. The one
preview policy whose workbook entry has no declared default effect is also
disabled.

Before enabling a disabled policy, add its real parameter values to
`policy_parameter_overrides` and update its `effective_effect` in
`policies.json`. Private endpoint, private DNS, diagnostic settings, Event Hub,
Storage, Log Analytics, and content-filter policies must not be enabled with
the neutral values.

## Usage

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Review the plan carefully. Several enabled defaults are `DeployIfNotExists`,
`Modify`, or `Deny` and therefore change or block resources at the management
group scope.
