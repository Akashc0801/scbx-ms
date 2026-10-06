# ================================
# Required Variables
# ================================

# ================================
# Naming Module Variables
# ================================

variable "env" {
  description = "The environment for the resource (e.g., dev, test, prod)"
  type        = string
}

variable "org" {
  type        = string
  description = "(Optional) Company/business unit code. Example: `scb`."
  default     = "scb"
}

variable "au" {
  description = "The application unit (AU) for the resource"
  type        = string
}

variable "owner" {
  description = "The owner of the resource"
  type        = string
}

variable "app_code" {
  description = "The application code for the resource"
  type        = string
}

variable "bu" {
  description = "The business unit for the resource"
  type        = string
}

variable "resource_type_code" {
  description = "The resource type code for the resource"
  type        = string
  default     = "mag"
}

variable "additional_name" {
  description = "Additional name to append to the resource name"
  type        = string
  default     = ""
}

variable "iterator" {
  description = "The iterator for the resource name"
  type        = string
  default     = "01"
}

variable "max_length" {
  description = "The maximum length of the resource name"
  type        = number
  default     = 260
}

variable "region_code" {
  description = "The region code for the resource"
  type        = string
  default     = ""
}

# ================================
# Mandatory Tags
# ================================

variable "environment" {
  description = "The environment tag value"
  type        = string
}

variable "business_owner" {
  description = "The business owner tag value"
  type        = string
}

variable "business_unit" {
  description = "The business unit tag value"
  type        = string
}

variable "criticality" {
  description = "The criticality tag value"
  type        = string
}

variable "cost_center" {
  description = "The cost center tag value"
  type        = string
}

variable "data_classification" {
  description = "The data classification tag value"
  type        = string
}

variable "compliance" {
  description = "The compliance tag value"
  type        = string
}

# ================================
# Optional Tags
# ================================

variable "region" {
  description = "The region tag value"
  type        = string
  default     = ""
}

variable "description" {
  description = "The description tag value"
  type        = string
  default     = ""
}

variable "notification_emails" {
  description = "The notification emails tag value"
  type        = list(string)
  default     = []
}

variable "additional_tags" {
  description = "Additional tags to apply to the resource"
  type        = map(string)
  default     = {}
}

# ================================
# Required Variables
# ================================

# Name comes from naming module - no need for name variable
# variable "name" {
#   description = "The name of the Action Group."
#   type        = string
# }

variable "resource_group_name" {
  description = "The name of the Resource Group where the Action Group should exist."
  type        = string
}

variable "short_name" {
  description = "The short name of the action group (max 12 characters). This will be used in SMS and email notifications."
  type        = string
  validation {
    condition     = length(var.short_name) <= 12
    error_message = "The short_name must be 12 characters or less."
  }
}

# ================================
# Optional Variables
# ================================

variable "enabled" {
  description = "Whether this action group is enabled. Defaults to true."
  type        = bool
  default     = true
}

# Location comes from naming module - no need for location variable
# variable "location" {
#   description = "The Azure Region where the Action Group should exist. Defaults to global."
#   type        = string
#   default     = "global"
# }

# Tags are now managed by naming module - no need for tags variable
# variable "tags" {
#   description = "A mapping of tags to assign to the resource."
#   type        = map(string)
#   default     = {}
# }

# ================================
# Receiver Variables
# ================================

variable "arm_role_receivers" {
  description = <<-EOT
    List of ARM Role Receivers. Sends notifications to users with specific Azure RBAC roles.
    Each receiver should contain:
    name: Name of the ARM role receiver
    role_id: The ARM role ID (e.g., Owner, Contributor, Reader)
    use_common_alert_schema: Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                    = string
    role_id                 = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = null
}

variable "automation_runbook_receivers" {
  description = <<-EOT
    List of Automation Runbook Receivers. Triggers Azure Automation runbooks.
    Each receiver should contain:
    name - Name of the automation runbook receiver
    automation_account_id - The automation account resource ID
    runbook_name - The name of the runbook
    webhook_resource_id - The webhook resource ID
    is_global_runbook - Whether the runbook is global
    service_uri - The URI of the webhook
    use_common_alert_schema - Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                    = string
    automation_account_id   = string
    runbook_name            = string
    webhook_resource_id     = string
    is_global_runbook       = bool
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = null
}

variable "azure_app_push_receivers" {
  description = <<-EOT
    List of Azure App Push Receivers. Sends notifications to the Azure mobile app.
    Each receiver should contain:
    name - Name of the Azure app push receiver
    email_address - The email address associated with the Azure mobile app account
  EOT
  type = list(object({
    name          = string
    email_address = string
  }))
  default = null
}

variable "azure_function_receivers" {
  description = <<-EOT
    List of Azure Function Receivers. Triggers Azure Functions.
    Each receiver should contain:
    name - Name of the Azure function receiver
    function_app_resource_id - The resource ID of the function app
    function_name - The name of the function
    http_trigger_url - The HTTP trigger URL of the function
    use_common_alert_schema - Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                     = string
    function_app_resource_id = string
    function_name            = string
    http_trigger_url         = string
    use_common_alert_schema  = optional(bool, true)
  }))
  default = null
}

variable "email_receivers" {
  description = <<-EOT
    List of Email Receivers. Sends email notifications.
    Each receiver should contain:
    name - Name of the email receiver
    email_address - The email address
    use_common_alert_schema - Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = null
}

variable "event_hub_receivers" {
  description = <<-EOT
    List of Event Hub Receivers. Sends alerts to Event Hub.
    Each receiver should contain:
    name - Name of the event hub receiver
    event_hub_namespace - The namespace of the event hub
    event_hub_name - The name of the event hub
    subscription_id - The subscription ID (optional)
    tenant_id - The tenant ID (optional)
    use_common_alert_schema - Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                    = string
    event_hub_namespace     = string
    event_hub_name          = string
    subscription_id         = optional(string)
    tenant_id               = optional(string)
    use_common_alert_schema = optional(bool, true)
  }))
  default = null
}

variable "itsm_receivers" {
  description = <<-EOT
    List of ITSM Receivers. Sends alerts to IT Service Management tools.
    Each receiver should contain:
    name - Name of the ITSM receiver
    workspace_id - The Log Analytics workspace ID
    connection_id - The ITSM connection ID
    ticket_configuration - JSON string for ticket configuration
    region - The Azure region
  EOT
  type = list(object({
    name                 = string
    workspace_id         = string
    connection_id        = string
    ticket_configuration = string
    region               = string
  }))
  default = null
}

variable "logic_app_receivers" {
  description = <<-EOT
    List of Logic App Receivers. Triggers Azure Logic Apps.
    Each receiver should contain:
    name - Name of the logic app receiver
    resource_id - The resource ID of the logic app
    callback_url - The callback URL of the logic app trigger
    use_common_alert_schema - Whether to use the common alert schema (default true)
  EOT
  type = list(object({
    name                    = string
    resource_id             = string
    callback_url            = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = null
}

variable "sms_receivers" {
  description = <<-EOT
    List of SMS Receivers. Sends SMS text messages.
    Each receiver should contain:
    name - Name of the SMS receiver
    country_code - The country code (e.g., "1" for US, "44" for UK)
    phone_number - The phone number without country code
  EOT
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = null
}

variable "voice_receivers" {
  description = <<-EOT
    List of Voice Receivers. Makes phone calls.
    Each receiver should contain:
    name - Name of the voice receiver
    country_code - The country code (e.g., "1" for US, "44" for UK)
    phone_number - The phone number without country code
  EOT
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = null
}

variable "webhook_receivers" {
  description = <<-EOT
    List of Webhook Receivers. Sends HTTP POST to custom endpoints.
    Each receiver should contain:
    name - Name of the webhook receiver
    service_uri - The URI to send the webhook request
    use_common_alert_schema - Whether to use the common alert schema (default true)
    aad_auth - Optional Azure AD authentication configuration with:
      object_id - The Azure AD object ID
      identifier_uri - The identifier URI
      tenant_id - The tenant ID
  EOT
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
    aad_auth = optional(object({
      object_id      = string
      identifier_uri = optional(string)
      tenant_id      = optional(string)
    }))
  }))
  default = null
}
