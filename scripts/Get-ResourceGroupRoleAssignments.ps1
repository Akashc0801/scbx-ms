<#
.SYNOPSIS
Exports all Azure RBAC assignments on a resource group, its resources, and ancestor scopes.
.DESCRIPTION
Read-only. Requires PowerShell 7, Azure CLI, az login, and permission to read role
assignments in the selected subscription and its ancestors. Always prompts for a
subscription name/ID and resource group. Does not change the active subscription.

Queries subscription-wide assignments to include descendant resources (including child
resource scopes), and separately queries the resource group with inherited assignments.
Filters out other resource groups and deduplicates by assignment ID. Covers every
principal type, not only managed identities. No templates or resource inventory required.

AssignmentLevel identifies ResourceGroup, Resource, or Inherited. Scope is the original
assignment scope. A resource-group assignment is inherited by resources in that group;
a resource assignment can also apply to its descendants. Inherited entries apply from
an ancestor of the selected group and are listed once, not repeated per resource.

RoleAssignments.csv includes principal object ID/type, role name/ID, scope, and conditions.
Principal names are not resolved, avoiding a Microsoft Graph permission requirement.
RoleAssignments.json preserves the raw returned assignments for the selected scope.
The script stops without exporting new reports if either query fails. A successful query
only reflects assignments visible to the caller; an empty result is not proof of no access.
Does not expand group membership, PIM eligibility, deny assignments, Key Vault access
policies, or service-specific roles (for example Cosmos DB SQL RBAC).
.EXAMPLE
.\Get-ResourceGroupRoleAssignments.ps1
.EXAMPLE
.\Get-ResourceGroupRoleAssignments.ps1 -OutputDirectory C:\Reports\ResourceGroupRbac
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = (Join-Path $HOME 'Downloads\resource-group-rbac')
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw 'Azure CLI is required. Install it and run az login.'
}

function Invoke-AzJson([string[]]$Arguments) {
    $stderr = [System.IO.Path]::GetTempFileName()
    try {
        $result = & az @Arguments --only-show-errors --output json 2> $stderr
        if ($LASTEXITCODE -ne 0) {
            throw "az $($Arguments -join ' ') failed: $(Get-Content -Raw $stderr)"
        }
        return ($result -join "`n") | ConvertFrom-Json -Depth 100
    } finally {
        Remove-Item -LiteralPath $stderr
    }
}

$subscriptions = @(Invoke-AzJson @('account', 'list') | Where-Object state -eq 'Enabled')
if (-not $subscriptions.Count) { throw 'No enabled subscriptions available. Run az login.' }
$subscriptions | Format-Table name, id, tenantId -AutoSize | Out-Host
$selection = (Read-Host 'Enter subscription name or subscription ID').Trim()
if (-not $selection) { throw 'Subscription selection cannot be empty.' }
$selected = @($subscriptions | Where-Object { $_.id -eq $selection -or $_.name -eq $selection })
if ($selected.Count -ne 1) {
    throw 'Select exactly one enabled subscription. Use its ID if names are duplicated.'
}
$subscription = $selected[0]
$resourceGroupName = (Read-Host 'Enter resource group name').Trim()
if (-not $resourceGroupName) { throw 'Resource group cannot be empty.' }
$group = Invoke-AzJson @('group', 'show', '--name', $resourceGroupName, '--subscription', $subscription.id)
if (-not $group.id) { throw 'Resource group lookup returned no resource ID.' }
$groupScope = $group.id.TrimEnd('/')
Write-Host "Reading Azure RBAC for $($subscription.name) / $($group.name)"

$all = @(Invoke-AzJson @('role', 'assignment', 'list', '--all', '--fill-principal-name', 'false',
    '--subscription', $subscription.id))
$ancestors = @(Invoke-AzJson @('role', 'assignment', 'list', '--scope', $groupScope,
    '--include-inherited', '--fill-principal-name', 'false', '--subscription', $subscription.id))
$seen = @{}
$rows = [System.Collections.Generic.List[object]]::new()
$raw = [System.Collections.Generic.List[object]]::new()
foreach ($assignment in @($all) + @($ancestors)) {
    if (-not $assignment.id -or -not $assignment.scope) {
        throw 'Role assignment response is missing an assignment ID or scope; report would be incomplete.'
    }
    $scope = $assignment.scope.TrimEnd('/')
    $level = if ($scope -eq $groupScope) {
        'ResourceGroup'
    } elseif ($scope.StartsWith("$groupScope/", [System.StringComparison]::OrdinalIgnoreCase)) {
        'Resource'
    } elseif ($assignment.scope -eq '/' -or
        $groupScope.StartsWith("$scope/", [System.StringComparison]::OrdinalIgnoreCase) -or
        $scope -match '^/providers/Microsoft.Management/managementGroups/[^/]+$') {
        'Inherited'
    } else {
        continue
    }
    if ($seen.ContainsKey($assignment.id)) { continue }
    $seen[$assignment.id] = $true
    $raw.Add($assignment)
    $rows.Add([pscustomobject]@{
        SubscriptionName = $subscription.name
        SubscriptionId = $subscription.id
        ResourceGroup = $group.name
        AssignmentLevel = $level
        RoleName = $assignment.roleDefinitionName
        RoleDefinitionId = $assignment.roleDefinitionId
        PrincipalId = $assignment.principalId
        PrincipalType = $assignment.principalType
        Scope = $assignment.scope
        Condition = $assignment.condition
        ConditionVersion = $assignment.conditionVersion
        AssignmentId = $assignment.id
    })
}

[void](New-Item -ItemType Directory -Path $OutputDirectory -Force)
$csvPath = Join-Path $OutputDirectory 'RoleAssignments.csv'
$jsonPath = Join-Path $OutputDirectory 'RoleAssignments.json'
$columns = @('SubscriptionName','SubscriptionId','ResourceGroup','AssignmentLevel','RoleName',
    'RoleDefinitionId','PrincipalId','PrincipalType','Scope','Condition','ConditionVersion','AssignmentId')
if ($rows.Count) {
    $rows | Sort-Object AssignmentLevel, Scope, RoleName, PrincipalId |
        Select-Object $columns | Export-Csv -LiteralPath $csvPath -NoTypeInformation
} else {
    Set-Content -LiteralPath $csvPath -Value (($columns | ForEach-Object { '"' + $_ + '"' }) -join ',')
}
ConvertTo-Json -InputObject $raw.ToArray() -Depth 100 | Set-Content -LiteralPath $jsonPath
$rows | Group-Object AssignmentLevel | Select-Object @{Name='AssignmentLevel'; Expression={$_.Name}}, Count |
    Format-Table -AutoSize | Out-Host
Write-Host "Total visible assignments: $($rows.Count)"
Write-Host "Reports: $([System.IO.Path]::GetFullPath($OutputDirectory))"
