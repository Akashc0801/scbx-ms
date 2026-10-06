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
  description = "(Required) Azure resource type abbreviation. Example: `ca`."
  default     = "ca"
}

variable "product_version" {
  type        = string
  description = "(Required) Product version. Example: `1.0.0`."
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

variable "app_support" {
  type        = string
  description = "(Required) Email address of the support team."
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.app_support))
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
  default     = "scb_container_app"
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
  description = "(Optional) Data classification level."
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
  validation {
    condition     = contains(["Live", "Non-Operational", "Decommissioned"], var.status)
    error_message = "Value must be one of: Live, Non-Operational, Decommissioned."
  }
  default = "Live"
}

# -
# Optional Tags
# -
variable "delete_after" {
  type        = string
  description = "(Optional) Date after which resource should be deleted (MM/DD/YYYY)."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Network tier (VNet/subnet name)."
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
  validation {
    condition     = var.auto_delete == "" || contains(["Yes", "No"], var.auto_delete)
    error_message = "Value must be Yes or No."
  }
  default = ""
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

variable "country" {
  type        = string
  description = "(Optional) Country code. Example: `th`."
  default     = "th"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
  }
  default = "sea"
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
  default     = 63
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
# Container App Environment Variables
# -
variable "create_container_app_environment" {
  type        = bool
  description = "(Optional) Whether to create a new Container App Environment. Defaults to `false`."
  default     = false
}

variable "container_app_environment_name" {
  type        = string
  description = "(Required) The name of the Container App Environment whether existing or a new one to be created."
}

variable "existing_container_app_environment_resourcegroup_name" {
  type        = string
  description = "(Optional) The name of the resource group where the existing Container App Environment resides. Required if `create_container_app_environment` is set to `false`."
  default     = null
}

variable "container_app_environment_dapr_application_insights_connection_string" {
  type        = string
  description = "(Optional) Application Insights connection string used by Dapr to export Service to Service communication telemetry."
  default     = null
  sensitive   = true
}

variable "container_app_environment_infrastructure_resource_group_name" {
  type        = string
  description = "(Optional) Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources. Only valid if a workload_profile is specified."
  default     = null
}

variable "container_app_environment_infrastructure_subnet_id" {
  type        = string
  description = "(Optional) The existing Subnet to use for the Container Apps Control Plane. The Subnet must have a `/21` or larger address space."
  default     = null
}

variable "container_app_environment_internal_load_balancer_enabled" {
  type        = bool
  description = "(Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Can only be set to `true` if `infrastructure_subnet_id` is specified."
  default     = null
}

variable "container_app_environment_log_analytics_workspace_id" {
  type        = string
  description = "(Optional) The ID for the Log Analytics Workspace to link this Container Apps Managed Environment to. Required if `logs_destination` is set to `log-analytics`."
  default     = null
}

variable "container_app_environment_logs_destination" {
  type        = string
  description = "(Optional) Where the application logs will be saved. Possible values include `log-analytics` and `azure-monitor`. Omitting this value will result in logs being streamed only."
  default     = null
  validation {
    condition     = var.container_app_environment_logs_destination == null || try(contains(["log-analytics", "azure-monitor"], var.container_app_environment_logs_destination), false)
    error_message = "Value must be one of: log-analytics, azure-monitor."
  }
}

variable "container_app_environment_mutual_tls_enabled" {
  type        = bool
  description = "(Optional) Should mutual transport layer security (mTLS) be enabled? Defaults to `false`."
  default     = false
}

variable "container_app_environment_public_network_access" {
  type        = string
  description = "(Optional) The public network access setting. Possible values are `Enabled` and `Disabled`."
  default     = "Disabled"
  validation {
    condition     = var.container_app_environment_public_network_access == null || contains(["Enabled", "Disabled"], var.container_app_environment_public_network_access)
    error_message = "Value must be one of: Enabled, Disabled."
  }
}

variable "container_app_environment_zone_redundancy_enabled" {
  type        = bool
  description = "(Optional) Should the Container App Environment be created with Zone Redundancy enabled? Defaults to `false`. Can only be set to `true` if `infrastructure_subnet_id` is specified."
  default     = null
}

variable "container_app_environment_workload_profiles" {
  type = list(object({
    name                  = string
    workload_profile_type = string
    maximum_count         = optional(number)
    minimum_count         = optional(number)
  }))
  description = <<DESCRIPTION
(Optional) Workload profiles for the Container App Environment.

- `name` - (Required) The name of the workload profile.
- `workload_profile_type` - (Required) Workload profile type. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16`, `E32`.
- `maximum_count` - (Optional) Maximum number of instances.
- `minimum_count` - (Optional) Minimum number of instances.
DESCRIPTION
  default     = null
}

variable "container_app_environment_identity" {
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  description = <<DESCRIPTION
(Optional) Managed identity configuration for the Container App Environment.

- `type` - (Required) The type of managed identity. Possible values are `SystemAssigned`, `UserAssigned`, and `SystemAssigned, UserAssigned`.
- `identity_ids` - (Optional) A set of User Assigned Managed Identity resource IDs. Required when `type` includes `UserAssigned`.
DESCRIPTION
  default     = null
}

# -
# Container App Variables
# -
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the Container App is to be created."
}

variable "revision_mode" {
  type        = string
  description = "(Required) The revisions operational mode for the Container App. Possible values include `Single` and `Multiple`."
  default     = "Single"
  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "Value must be one of: Single, Multiple."
  }
}

variable "template" {
  type = object({
    min_replicas    = optional(number)
    max_replicas    = optional(number, 10)
    revision_suffix = optional(string)

    containers = list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = number
      image   = string
      memory  = string
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      liveness_probe = optional(list(object({
        failure_count_threshold = optional(number, 3)
        host                    = optional(string)
        initial_delay           = optional(number, 1)
        interval_seconds        = optional(number, 10)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number, 1)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      readiness_probe = optional(list(object({
        failure_count_threshold = optional(number, 3)
        host                    = optional(string)
        initial_delay           = optional(number, 0)
        interval_seconds        = optional(number, 10)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number, 3)
        timeout                 = optional(number, 1)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      startup_probe = optional(list(object({
        failure_count_threshold = optional(number, 3)
        host                    = optional(string)
        initial_delay           = optional(number, 0)
        interval_seconds        = optional(number, 10)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number, 1)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      volume_mounts = optional(list(object({
        name = string
        path = string
      })))
    }))

    init_container = optional(list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = optional(number)
      image   = string
      memory  = optional(string)
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      volume_mounts = optional(list(object({
        name = string
        path = string
      })))
    })))

    azure_queue_scale_rule = optional(list(object({
      name         = string
      queue_length = number
      queue_name   = string
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })))

    custom_scale_rule = optional(list(object({
      custom_rule_type = string
      metadata         = map(string)
      name             = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    })))

    http_scale_rule = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))

    tcp_scale_rule = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))

    volume = optional(list(object({
      name         = string
      storage_name = optional(string)
      storage_type = optional(string, "EmptyDir")
    })))
  })
  description = <<DESCRIPTION
The template block for the Container App.

- `min_replicas` - (Optional) The minimum number of replicas for this container.
- `max_replicas` - (Optional) The maximum number of replicas for this container. Defaults to `10`.
- `revision_suffix` - (Optional) The suffix for the revision.
- `containers` - (Required) One or more container blocks.
- `init_container` - (Optional) One or more init container blocks.
- `azure_queue_scale_rule` - (Optional) Azure Queue scaling rules.
- `custom_scale_rule` - (Optional) Custom scaling rules.
- `http_scale_rule` - (Optional) HTTP scaling rules.
- `tcp_scale_rule` - (Optional) TCP scaling rules.
- `volume` - (Optional) Volume definitions.
DESCRIPTION
}

variable "ingress" {
  type = object({
    allow_insecure_connections = optional(bool, false)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number)
    external_enabled           = optional(bool, false)
    target_port                = number
    transport                  = optional(string, "auto")

    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool, false)
      revision_suffix = optional(string)
      percentage      = number
    }))

    cors_policy = optional(object({
      allow_credentials = optional(bool, false)
      allowed_headers   = optional(list(string))
      allowed_methods   = optional(list(string))
      allowed_origins   = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
    }))

    custom_domain = optional(object({
      certificate_binding_type = optional(string, "Disabled")
      certificate_id           = string
      name                     = string
    }))

    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })))
  })
  default     = null
  description = <<DESCRIPTION
Ingress configuration for the Container App.

- `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections? Defaults to `false`.
- `client_certificate_mode` - (Optional) The mode for client certificate authentication. Possible values include `optional` and `required`.
- `exposed_port` - (Optional) The exposed port on the container for the Ingress traffic.
- `external_enabled` - (Optional) Are connections from outside the Container App Environment enabled? Defaults to `false`.
- `target_port` - (Required) The target port on the container for the Ingress traffic.
- `transport` - (Optional) The transport method. Possible values include `auto`, `http`, `http2`, and `tcp`. Defaults to `auto`.
- `traffic_weight` - (Required) Traffic weight configuration blocks.
- `cors_policy` - (Optional) CORS policy configuration.
- `custom_domain` - (Optional) Custom domain configuration.
- `ip_security_restriction` - (Optional) IP security restriction rules.
DESCRIPTION
}

variable "dapr" {
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string, "http")
  })
  default     = null
  description = <<DESCRIPTION
Dapr configuration for the Container App.

- `app_id` - (Required) The Dapr Application Identifier.
- `app_port` - (Optional) The port which the application is listening on.
- `app_protocol` - (Optional) The protocol for the app. Possible values include `http` and `grpc`. Defaults to `http`.
DESCRIPTION
}

variable "registries" {
  type = list(object({
    identity             = optional(string)
    password_secret_name = optional(string)
    server               = string
    username             = optional(string)
  }))
  default     = null
  description = <<DESCRIPTION
Container registry configuration for pulling images.

- `identity` - (Optional) Resource ID for the User Assigned Managed Identity to use when pulling from the Container Registry.
- `password_secret_name` - (Optional) The name of the Secret Reference containing the password value.
- `server` - (Required) The hostname for the Container Registry.
- `username` - (Optional) The username to use for this Container Registry.
DESCRIPTION
}

variable "secrets" {
  type = list(object({
    name                = string
    identity            = optional(string)
    key_vault_secret_id = optional(string)
    value               = optional(string)
  }))
  default     = null
  sensitive   = true
  description = <<DESCRIPTION
Secret configuration for the Container App.

- `name` - (Required) The secret name.
- `identity` - (Optional) The identity associated with the secret.
- `key_vault_secret_id` - (Optional) The URL of the Azure Key Vault secret.
- `value` - (Optional) The value for this secret.
DESCRIPTION
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Managed identity configuration for the Container App.

- `system_assigned` - (Optional) Enable system-assigned managed identity. Defaults to `false`.
- `user_assigned_resource_ids` - (Optional) A set of user-assigned managed identity resource IDs.
DESCRIPTION
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "(Optional) Workload profile name to pin for container app execution."
}

variable "max_inactive_revisions" {
  type        = number
  default     = null
  description = "(Optional) Max inactive revisions a Container App can have."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the Container App.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) Skip the AAD check for service principals. Defaults to `false`.
- `condition` - (Optional) The condition for the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Valid values are `2.0`.
- `delegated_managed_identity_resource_id` - (Optional) The delegated managed identity resource ID.
- `principal_type` - (Optional) The type of the principal. Possible values are `User`, `Group` and `ServicePrincipal`.
DESCRIPTION
  nullable    = false
}

variable "container_app_environment_private_endpoint" {
  type = object({
    name                 = string
    location             = string
    resource_group_name  = string
    subnet_id            = string
    private_dns_zone_ids = list(string)
  })

  default = null
}

variable "role_assignments_cae" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = optional(string, null)
    scope                                  = optional(string, null)
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the Container App.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) Skip the AAD check for service principals. Defaults to `false`.
- `condition` - (Optional) The condition for the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Valid values are `2.0`.
- `delegated_managed_identity_resource_id` - (Optional) The delegated managed identity resource ID.
- `principal_type` - (Optional) The type of the principal. Possible values are `User`, `Group` and `ServicePrincipal`.
DESCRIPTION
  nullable    = false
}