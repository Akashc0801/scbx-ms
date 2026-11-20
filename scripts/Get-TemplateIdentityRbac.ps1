<#
.SYNOPSIS
Discovers managed identities and audits their Azure RBAC in a resource group.
.DESCRIPTION
Read-only. Requires PowerShell 7, Azure CLI, az login, and read permissions for resources
and role assignments. Every run prompts for a subscription name/ID and resource group.
Templates no longer limit discovery. The filename is retained for existing users.

Checks every resource returned by az resource list for system-assigned identities,
attached user-assigned identities, and standalone user-assigned identity resources.
Externally hosted user-assigned identities attached to these resources are also resolved.
ResourceCoverage.csv records all enumerated resources, including those without identities.
ARM's generic resource list may not enumerate provider-specific untracked child resources.

Lists direct principal assignments anywhere in the selected resource group, plus visible
assignments inherited from subscription and management-group scopes. It does not list
assignments outside the selected group, except ancestors that apply to the group.
It does not calculate effective permissions, group-derived access, PIM eligibility, deny
assignments, Key Vault access policies, or service-specific roles such as Cosmos DB SQL RBAC.
An identity having no assignments here does not mean it has no permissions elsewhere.

Writes Inventory.csv, Bindings.csv, ResourceCoverage.csv, AzureRoleAssignments.csv, and
Errors.csv. Failed resource or role lookups are reported and cause a terminating error
after partial reports are exported. No assignments or resources are changed.
.EXAMPLE
.\Get-TemplateIdentityRbac.ps1
Prompts for scope and writes reports under Downloads\identity-rbac.
.EXAMPLE
.\Get-TemplateIdentityRbac.ps1 -OutputDirectory C:\Reports\IdentityRbac
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $HOME 'Downloads\identity-rbac')
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
$matches = @($subscriptions | Where-Object { $_.id -eq $selection -or $_.name -eq $selection })
if ($matches.Count -ne 1) { throw 'Subscription selection must match exactly one enabled subscription. Use its ID if names are duplicated.' }
$subscription = $matches[0]
$resourceGroupName = (Read-Host 'Enter resource group name').Trim()
if (-not $resourceGroupName) { throw 'Resource group cannot be empty.' }
$group = Invoke-AzJson @('group', 'show', '--name', $resourceGroupName, '--subscription', $subscription.id)
if (-not $group.id) { throw 'Resource group lookup returned no resource ID.' }
$groupScope = $group.id.TrimEnd('/')
$subscriptionScope = "/subscriptions/$($subscription.id)"
Write-Host "Auditing $($subscription.name) / $($group.name)"

$identities = @{}
$bindings = [System.Collections.Generic.List[object]]::new()
$coverage = [System.Collections.Generic.List[object]]::new()
$failures = [System.Collections.Generic.List[object]]::new()
$assignments = [System.Collections.Generic.List[object]]::new()
function Add-Identity([string]$Id, [string]$Kind, [string]$AttachedResource, [string]$PrincipalId, [string]$TenantId) {
    if (-not $identities.ContainsKey($Id)) {
        $identities[$Id] = [pscustomobject]@{
            IdentityName = ($Id -split '/')[-1]
            IdentityType = $Kind
            ResourceId = $Id
            PrincipalId = $PrincipalId
            TenantId = $TenantId
            LookupStatus = 'NotQueried'
            AssignmentCount = 0
        }
    } elseif ($PrincipalId) {
        $identities[$Id].PrincipalId = $PrincipalId
        $identities[$Id].TenantId = $TenantId
    }
    $bindings.Add([pscustomobject]@{
        IdentityResourceId = $Id
        IdentityType = $Kind
        Relationship = if ($AttachedResource) { 'Attached' } else { 'StandaloneResource' }
        AttachedResourceId = $AttachedResource
    })
}

$resources = @(Invoke-AzJson @('resource', 'list', '--resource-group', $group.name, '--subscription', $subscription.id))
foreach ($listed in $resources) {
    $row = [pscustomobject]@{ResourceId=$listed.id; ResourceType=$listed.type; IdentityType=''; LookupStatus='NotQueried'}
    $coverage.Add($row)
    try {
        $resource = Invoke-AzJson @('resource', 'show', '--ids', $listed.id, '--subscription', $subscription.id)
        if (-not $resource.id) { throw 'Resource lookup returned no resource ID.' }
        $row.IdentityType = $resource.identity.type
        if ($resource.type -eq 'Microsoft.ManagedIdentity/userAssignedIdentities') {
            Add-Identity $resource.id 'UserAssigned' '' $resource.properties.principalId $resource.properties.tenantId
        }
        if ($resource.identity.type -match 'SystemAssigned') {
            if (-not $resource.identity.principalId) { throw 'System-assigned identity has no principalId.' }
            Add-Identity $resource.id 'SystemAssigned' $resource.id $resource.identity.principalId $resource.identity.tenantId
        }
        if ($resource.identity.userAssignedIdentities) {
            foreach ($reference in $resource.identity.userAssignedIdentities.PSObject.Properties) {
                Add-Identity $reference.Name 'UserAssigned' $resource.id '' ''
            }
        }
        $row.LookupStatus = 'Checked'
    } catch {
        $row.LookupStatus = 'Failed'
        $failures.Add([pscustomobject]@{ResourceId=$listed.id; Stage='DiscoverIdentity'; Error=$_.Exception.Message})
    }
}

foreach ($identity in $identities.Values) {
    try {
        if (-not $identity.PrincipalId) {
            $resource = Invoke-AzJson @('resource', 'show', '--ids', $identity.ResourceId)
            if (-not $resource.properties.principalId) { throw 'User-assigned identity has no principalId.' }
            $identity.PrincipalId = $resource.properties.principalId
            $identity.TenantId = $resource.properties.tenantId
        }
        if ($identity.TenantId -ne $subscription.tenantId) { throw 'Identity tenant differs from the selected subscription tenant.' }
        $identity.LookupStatus = 'Resolved'
    } catch {
        $identity.LookupStatus = 'Failed'
        $failures.Add([pscustomobject]@{ResourceId=$identity.ResourceId; Stage='ResolveIdentity'; Error=$_.Exception.Message})
        continue
    }
    try {
        $roles = @(Invoke-AzJson @('role', 'assignment', 'list', '--assignee-object-id', $identity.PrincipalId,
            '--all', '--fill-principal-name', 'false', '--subscription', $subscription.id))
        $roles += @(Invoke-AzJson @('role', 'assignment', 'list', '--assignee-object-id', $identity.PrincipalId,
            '--include-inherited', '--fill-principal-name', 'false',
            '--scope', $groupScope, '--subscription', $subscription.id))
        $seen = @{}
        foreach ($role in $roles) {
            $scope = ([string]$role.scope).TrimEnd('/')
            $inGroup = $scope -eq $groupScope -or $scope.StartsWith("$groupScope/", [System.StringComparison]::OrdinalIgnoreCase)
            $inherited = $scope -eq $subscriptionScope -or $scope -match '^/providers/Microsoft.Management/managementGroups/[^/]+$' -or $role.scope -eq '/'
            if (-not ($inGroup -or $inherited) -or $role.principalId -ne $identity.PrincipalId) { continue }
            if ($seen.ContainsKey($role.id)) { continue }
            $seen[$role.id] = $true
            $assignments.Add([pscustomobject]@{
                IdentityName=$identity.IdentityName; IdentityType=$identity.IdentityType
                IdentityResourceId=$identity.ResourceId; PrincipalId=$identity.PrincipalId
                RoleName=$role.roleDefinitionName; RoleDefinitionId=$role.roleDefinitionId
                Scope=$role.scope; InheritedByResourceGroup=$inherited
                Condition=$role.condition; ConditionVersion=$role.conditionVersion; AssignmentId=$role.id
            })
            $identity.AssignmentCount++
        }
        $identity.LookupStatus = if ($identity.AssignmentCount) { 'Checked' } else { 'NoAssignmentsInSelectedScope' }
    } catch {
        $identity.LookupStatus = 'RbacLookupFailed'
        $failures.Add([pscustomobject]@{ResourceId=$identity.ResourceId; Stage='ListRbac'; Error=$_.Exception.Message})
    }
}

[void](New-Item -ItemType Directory -Path $OutputDirectory -Force)
function Export-Rows($Rows, [string]$Name, [string[]]$Columns) {
    $path = Join-Path $OutputDirectory $Name
    if (@($Rows).Count) { $Rows | Select-Object $Columns | Export-Csv -LiteralPath $path -NoTypeInformation }
    else { Set-Content -LiteralPath $path -Value (($Columns | ForEach-Object { '"' + $_ + '"' }) -join ',') }
}
Export-Rows @($identities.Values | Sort-Object IdentityType, ResourceId) 'Inventory.csv' @('IdentityName','IdentityType','ResourceId','PrincipalId','TenantId','LookupStatus','AssignmentCount')
Export-Rows $bindings.ToArray() 'Bindings.csv' @('IdentityResourceId','IdentityType','Relationship','AttachedResourceId')
Export-Rows $coverage.ToArray() 'ResourceCoverage.csv' @('ResourceId','ResourceType','IdentityType','LookupStatus')
Export-Rows $assignments.ToArray() 'AzureRoleAssignments.csv' @('IdentityName','IdentityType','IdentityResourceId','PrincipalId','RoleName','RoleDefinitionId','Scope','InheritedByResourceGroup','Condition','ConditionVersion','AssignmentId')
Export-Rows $failures.ToArray() 'Errors.csv' @('ResourceId','Stage','Error')
$identities.Values | Sort-Object IdentityType, ResourceId |
    Format-Table IdentityName, IdentityType, LookupStatus, AssignmentCount -AutoSize
Write-Host "Resources enumerated: $($resources.Count); managed identities discovered: $($identities.Count)"
Write-Host "Reports: $([System.IO.Path]::GetFullPath($OutputDirectory))"
if ($failures.Count) { throw "$($failures.Count) lookup(s) failed. See Errors.csv; results are incomplete." }
