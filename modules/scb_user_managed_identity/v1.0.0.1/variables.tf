# Location comes from naming module - no need for location variable
# variable "location" {
#   type        = string
#   description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
#   nullable    = false
# }

# Name comes from naming module - no need for name variable
# variable "name" {
#   type        = string
#   description = "The name of the this resource."
#
#   validation {
#     condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{2,127}$", var.name))
#     error_message = "The name must start with a letter or number, be between 3 and 128 characters long, and can only contain alphanumerics, hyphens, and underscores."
#   }
# }

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "federated_identity_credentials" {
  type = map(object({
    issuer   = string
    subject  = string
    audience = list(string)
  }))
  default     = {}
  nullable    = true
  description = <<DESCRIPTION
Optional map of federated identity credentials to create on the user assigned identity.
Map key is used as credential name. If null, no credentials are created.

Example:
{
  "github-snapshot" = {
    issuer   = "https://token.actions.githubusercontent.com"
    subject  = "repo:my-org/*:environment:snapshot"
    audience = ["api://AzureADTokenExchange"]
  }
}
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    scope                                  = string
    role_definition_id_or_name             = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, true)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
Optional map of role assignments to create for the managed identity principal.
Map key is deliberately arbitrary to avoid plan-time unknown key issues.

- `scope` - The scope at which the role assignment applies.
- `role_definition_id_or_name` - The ID or name of the role definition to assign.
- `description` - (Optional) Description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If true, skips Azure AD checks for service principals. Defaults to true.
- `condition` - (Optional) Role assignment condition.
- `condition_version` - (Optional) Condition syntax version (for example, `2.0` when using `condition`).
- `delegated_managed_identity_resource_id` - (Optional) Delegated managed identity resource ID used for cross-tenant scenarios.
- `principal_type` - (Optional) Principal type. Possible values include `User`, `Group`, and `ServicePrincipal`.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for role_assignment in values(var.role_assignments) :
      length(trimspace(role_assignment.scope)) > 0 && length(trimspace(role_assignment.role_definition_id_or_name)) > 0
    ])
    error_message = "Each role assignment must have non-empty `scope` and `role_definition_id_or_name` values."
  }

  validation {
    condition = alltrue([
      for role_assignment in values(var.role_assignments) :
      role_assignment.condition_version == null ? true : (role_assignment.condition != null ? length(trimspace(role_assignment.condition)) > 0 : false)
    ])
    error_message = "`condition_version` can only be set when `condition` is also set and non-empty."
  }

  validation {
    condition = alltrue([
      for role_assignment in values(var.role_assignments) :
      role_assignment.principal_type == null ? true : contains(["User", "Group", "ServicePrincipal"], role_assignment.principal_type)
    ])
    error_message = "`principal_type` must be one of: `User`, `Group`, `ServicePrincipal` (or null)."
  }
}

# Tags are now managed by naming module - no need for tags variable
# variable "tags" {
#   type        = map(string)
#   default     = null
#   description = "(Optional) Tags of the resource."
# }

# -
# Naming Module Variables
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit (AU) code. Example: `0233985`."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value for \"au\" must be of numeric characters."
  }
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation. Example: `id`."
  default     = "id"
}

variable "product_version" {
  type        = string
  description = "(Optional) Product version. Example: `1.0.0`."
  default     = "1.0.0.0"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or scb."
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
}

variable "app_support" {
  type        = string
  description = "(Optional) Email address of the support team."
  default     = ""
  validation {
    condition     = var.app_support == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.app_support))
    error_message = "Value for \"app_support\" must be a valid email address."
  }
}

variable "business_unit" {
  type        = string
  description = "(Required) Department that owns the resources."
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "type" {
  type        = string
  description = "(Required) Infrastructure or business service type."
  default     = "Infrastructure"
}

# -
# Mandatory DevOps Tags
# -
variable "product_name" {
  type        = string
  description = "(Required) Terraform Module name."
  default     = "scb_user_managed_identity"
}

# -
# Mandatory Finance Tags
# -
variable "cost_center" {
  type        = string
  description = "(Required) Cost center that should bear the costs."
  default     = ""
}

variable "cost_allocation_unit" {
  type        = string
  default     = ""
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  description = "(Required) Maximum budget allocated."
  default     = ""
}

variable "cost_alert_threshold" {
  type        = string
  description = "(Required) Cost threshold for triggering alerts."
  default     = ""
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  description = "(optional) Data classification level."
  default     = ""
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  validation {
    condition     = contains(["Yes", "No"], var.compliance_required)
    error_message = "Value must be Yes or No."
  }
  default = "No"
}

variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
  default     = "None"
}

# -
# Mandatory Operation Tags
# -
variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "status" {
  type        = string
  description = "(Required) Status of the resource."
  default     = "Live"
}

# -
# Optional Tags for User Managed Identity
# -
variable "delete_after" {
  type        = string
  description = "(Optional) Date after which resource should be deleted (MM/DD/YYYY)."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Network tier."
  default     = ""
}

variable "app_id" {
  type        = string
  description = "(Optional) Application ID from CMDB."
  default     = ""
}

variable "auto_delete" {
  type        = string
  description = "(Optional) Should resource be auto-deleted? (Yes/No)."
  default     = ""
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Brief description of the resource purpose."
  default     = ""
}

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  default     = ""
}

variable "disaster_recovery" {
  type        = string
  description = "(Optional) DR requirements."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of emails for notifications."
  default     = [""]
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

# -
# Optional Naming Variables
# -
variable "org" {
  type        = string
  description = "(Optional) Company/business unit code. Example: `scb`."
  default     = "scb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code."
  default     = "sea"
}

variable "location_region_code" {
  type        = string
  description = "(Optional) SCB region code used only to select the Azure location when region_code is null. Must be one of: `[ea,sea,eu,myw,sg,idc]`."
  default     = null

  validation {
    condition     = var.location_region_code == null ? true : contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.location_region_code)
    error_message = "Value of \"location_region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
  }
}

variable "naming_format" {
  type        = string
  description = "(Optional) Naming layout passed to the SCB naming module: `legacy` (org-type-app_code-env-region-base_name) or `workload` (org-type-app_code-base_name-env-region)."
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "workload"], var.naming_format)
    error_message = "Value of \"naming_format\" must be either \"legacy\" or \"workload\"."
  }
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness."
  default     = null
}

variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

variable "base_name" {
  type        = string
  description = "(Optional) Application/Infrastructure base name."
  default     = null
}

variable "max_length" {
  type        = number
  description = "(Optional) Set the maximum length of the generated name."
  default     = 128
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) When set to true, it will remove all '-' separators from the generated name."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) When set to true, it will add a random number at the name's end."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the random number generated."
  default     = 2
}

# -
# Additional Optional Tags
# -
variable "integration_id" {
  type        = string
  description = "(Optional) Integration ID for the resource."
  default     = ""
}

variable "experiment_phase" {
  type        = string
  description = "(Optional) Experiment phase for sandbox environments."
  default     = ""
}

variable "os" {
  type        = string
  description = "(Optional) Operating System type."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Last VM access timestamp."
  default     = ""
}

variable "service" {
  type        = string
  description = "(Required) Service name or identifier."
}

variable "retention" {
  type        = string
  description = "(Optional) Data retention policy."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox environment."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window schedule."
  default     = ""
}

