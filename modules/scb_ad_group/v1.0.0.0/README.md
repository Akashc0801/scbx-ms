# scb_ad_group

Terraform module to create and manage Azure Active Directory groups with a standardised naming convention.

## Naming Convention

Groups are named using the following structure, with empty segments automatically omitted:

```
<TYPE>-<TIER>-<SCOPE>-<BU_CODE>-<APP_CODE>-<ROLECODE>-<FUNCTION>-<ENV>-<REGION>
```

| Segment    | Required | Allowed Values                                                        |
|------------|----------|-----------------------------------------------------------------------|
| `type`     | Yes      | `SG`, `RAG`                                                          |
| `tier`     | Yes      | `T0`, `T1`, `T2`, `T3`                                               |
| `scope`    | No       | `Root`, `SCB`, `CEN`, `REG`, `BU`, `SBX`, `APP`, `APL`, `DATA`       |
| `bu_code`  | No*      | Any string (*required if scope is `BU` or `APP`)                      |
| `app_code` | No       | Any string (required if scope is `APP` or `APL`)                      |
| `rolecode` | Yes      | Short code for the Entra role or functional group                     |
| `function` | Yes      | `Members`, `Approvers`, `Owners`                                      |
| `env`      | No       | `Prod`, `NonProd`, `Dev`, `Test`, `UAT`, `SBX`                       |
| `region`   | No       | `MY`, `SG`, `ID`, `AU`                                               |

**Example:** `RAG-T0-CEN-PlatformAdmin-Members-Prod`

## Usage

```hcl
module "scb-ad-group" {
  source = "../../modules/scb_ad_group/v1.0.0.0"

  for_each = var.ad_groups

  type                    = each.value.type
  tier                    = each.value.tier
  scope                   = each.value.scope
  bu_code                 = each.value.bu_code
  app_code                = each.value.app_code
  rolecode                = each.value.rolecode
  function                = each.value.function
  env                     = each.value.env
  region                  = each.value.region
  administrative_unit_ids = each.value.administrative_unit_ids
  assignable_to_role      = each.value.assignable_to_role
  description             = each.value.description
  members                 = each.value.members
  security_enabled        = each.value.security_enabled
  owners                  = each.value.owners
  prevent_duplicate_names = each.value.prevent_duplicate_names
  visibility              = each.value.visibility
}
```

## Requirements

| Name      | Version            |
|-----------|--------------------|
| terraform | >= 1.9, < 2.0     |
| azuread   | >= 2.46, < 4.0    |

## Providers

| Name    | Description                                        |
|---------|----------------------------------------------------|
| azuread | Used to manage the AD group and read client config |

## Resources

| Name                                  | Type     |
|---------------------------------------|----------|
| `azuread_group.scb-ad-group`         | Resource |
| `azuread_client_config.current`      | Data     |

## Inputs

| Name                      | Type          | Default | Required | Description                                                                                    |
|---------------------------|---------------|---------|----------|------------------------------------------------------------------------------------------------|
| `type`                    | `string`      | �       | Yes      | Group type (`SG` or `RAG`).                                                                    |
| `tier`                    | `string`      | �       | Yes      | Tier (`T0`�`T3`).                                                                              |
| `scope`                   | `string`      | `""`    | No       | Scope segment of the group name.                                                               |
| `bu_code`                 | `string`      | `""`    | No*      | Business unit code. *Required if scope is `BU` or `APP`.                                       |
| `app_code`                | `string`      | `""`    | No       | Application code. Required if scope is `APP` or `APL`.                                         |
| `rolecode`                | `string`      | �       | Yes      | Short code for the Entra role or functional group.                                             |
| `function`                | `string`      | �       | Yes      | Function segment (`Members`, `Approvers`, or `Owners`).                                        |
| `env`                     | `string`      | `""`    | No       | Environment segment.                                                                           |
| `region`                  | `string`      | `""`    | No       | Region segment.                                                                                |
| `administrative_unit_ids` | `set(string)` | `[]`    | No       | Object IDs of administrative units in which the group is a member.                             |
| `assignable_to_role`      | `bool`        | `false` | No       | Whether this group can be assigned to an Azure AD role. Only for security-enabled groups.       |
| `description`             | `string`      | `""`    | No       | Group description. Omitted if left empty.                                                      |
| `members`                 | `set(string)` | `[]`    | No       | Object IDs of members (Users, Groups, or Service Principals).                                  |
| `security_enabled`        | `bool`        | `true`  | No       | Whether the group is a security group.                                                         |
| `owners`                  | `set(string)` | `[]`    | No       | Object IDs of owners. The deploying service principal is always added automatically.            |
| `prevent_duplicate_names` | `bool`        | `false` | No       | If `true`, returns an error if a group with the same name already exists.                      |
| `visibility`              | `string`      | `null`  | No       | Group visibility: `Private`, `Public`, or `Hiddenmembership`.                                  |

## Outputs

| Name              | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `object_id`       | The object ID of the group.                                                   |
| `display_name`    | The display name of the group.                                                |
| `proxy_addresses` | List of email addresses for the group that direct to the same group mailbox.  |
