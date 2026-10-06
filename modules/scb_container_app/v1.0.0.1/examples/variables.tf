# -
# Common Variables
# -
variable "location" {
  type        = string
  description = "(Required) Azure region for the resource group."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group."
}

# -
# Naming Variables
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit (AU) code."
}

variable "app_code" {
  type        = string
  description = "(Required) Application code."
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code."
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "region_code" {
  type        = string
  description = "(Required) Region code."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation."
  default     = "ca"
}

variable "product_version" {
  type        = string
  description = "(Required) Product version."
}

# -
# Mandatory Business Tags
# -
variable "business_unit" {
  type        = string
  description = "(Required) Department that owns the resources."
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "app_support" {
  type        = string
  description = "(Required) Email address of the support team."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

# -
# Container Apps Map
# -
variable "container_apps" {
  type = map(object({
    iterator  = string
    base_name = string

    # Container App Environment
    create_container_app_environment                     = optional(bool, false)
    container_app_environment_name                       = string
    container_app_environment_logs_destination           = optional(string)
    container_app_environment_log_analytics_workspace_id = optional(string)

    # Container App
    revision_mode = optional(string, "Single")

    template = object({
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
      }))
      init_container = optional(list(object({
        args    = optional(list(string))
        command = optional(list(string))
        cpu     = optional(number)
        image   = string
        memory  = optional(string)
        name    = string
      })))
      custom_scale_rule = optional(list(object({
        custom_rule_type = string
        metadata         = map(string)
        name             = string
      })))
      http_scale_rule = optional(list(object({
        concurrent_requests = string
        name                = string
      })))
    })

    ingress = optional(object({
      allow_insecure_connections = optional(bool, false)
      external_enabled           = optional(bool, false)
      target_port                = number
      transport                  = optional(string, "auto")
      traffic_weight = list(object({
        label           = optional(string)
        latest_revision = optional(bool, false)
        revision_suffix = optional(string)
        percentage      = number
      }))
    }))

    registries = optional(list(object({
      identity             = optional(string)
      password_secret_name = optional(string)
      server               = string
      username             = optional(string)
    })))

    secrets = optional(list(object({
      name                = string
      identity            = optional(string)
      key_vault_secret_id = optional(string)
      value               = optional(string)
    })))

    dapr = optional(object({
      app_id       = string
      app_port     = optional(number)
      app_protocol = optional(string, "http")
    }))

    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})
  }))
  description = "Map of container app configurations. Each key is a logical name for the container app."
}
