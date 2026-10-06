variable "apim_name" {
  type        = string
  description = "Existing APIM name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group of APIM"
}

variable "api_version_sets" {
  type = map(object({
    display_name      = string
    versioning_scheme = string
  }))
  default = {}
}

#################################################
# Optional: Common Policy Variables
#################################################

variable "common_policy_vars" {
  description = "Common variables available to all policy templates"
  type        = map(any)
  default     = {}
}

# variable "apis" {
#   type = map(object({
#     display_name          = string
#     revision              = string
#     path                  = string
#     protocols             = list(string)
#     service_url           = string
#     subscription_required = bool
#     api_version_set_name  = optional(string)
#     import = optional(object({
#       content_format = string
#       content_value  = string
#     }))
#     policy = optional(object({
#       policy_template = optional(string)
#       policy_vars     = optional(map(string))
#       xml_content     = optional(string)
#       xml_link        = optional(string)
#     }))
#     operations = map(object({
#       display_name    = string
#       method          = string
#       url_template    = string
#       policy          = optional(object({
#         policy_template = optional(string)
#         policy_vars     = optional(map(string))
#         xml_content     = optional(string)
#         xml_link        = optional(string)
#       }))
#       template_parameters = optional(list(object({
#         name          = string
#         required      = optional(bool)
#         type          = optional(string)
#         default_value = optional(string)
#         description   = optional(string)
#         values        = optional(list(string))
#       })))
#     }))
#   }))
# }
variable "apis" {
  type = map(object({
    # Basic API properties
    display_name = string
    path         = string
    # protocols             = optional(list(string), ["https"]) // Not required to pass the value - Enforced by module security baseline - HTTPS only. The value from tfvars will be ignored.
    revision              = optional(string, "1")
    service_url           = optional(string)
    description           = optional(string)
    subscription_required = optional(bool, true)

    # API versioning
    api_version          = optional(string)
    api_version_set_name = optional(string)
    revision_description = optional(string)

    # Import configuration (OpenAPI, WSDL, WADL, etc.)
    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(object({
        service_name  = string
        endpoint_name = string
      }))
    }))

    # Source API for cloning
    source_api_id = optional(string)

    # OAuth2 Authorization
    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = optional(string)
    }))

    # OpenID Connect Authentication
    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = optional(list(string))
    }))

    # Subscription key parameter names
    subscription_key_parameter_names = optional(object({
      header = string
      query  = string
    }))

    # Contact information
    contact = optional(object({
      email = optional(string)
      name  = optional(string)
      url   = optional(string)
    }))

    # License information
    license = optional(object({
      name = optional(string)
      url  = optional(string)
    }))

    terms_of_service_url = optional(string)

    # API-level policy
    policy = optional(object({
      policy_template = optional(string)
      policy_vars     = optional(map(string))
      xml_content     = optional(string)
      xml_link        = optional(string)
    }))

    # API operations
    operations = optional(map(object({
      display_name = string
      method       = string
      url_template = string
      description  = optional(string)

      # Template parameters (URL path parameters)
      template_parameters = optional(list(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(list(string))
      })))

      # Request configuration
      request = optional(object({
        description = optional(string)

        query_parameters = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      }))

      # Response configuration
      responses = optional(list(object({
        status_code = number
        description = optional(string)

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      })))

      # Operation-level policy
      policy = optional(object({
        policy_template = optional(string)
        policy_vars     = optional(map(string))
        xml_content     = optional(string)
        xml_link        = optional(string)
      })),
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
APIs for the API Management service. APIs define the operations available to API consumers.

- `display_name` - (Required) The display name of the API.
- `path` - (Required) The relative path for the API. Must be unique within the API Management service.
- `protocols` - protocols are enforced by the module security baseline (HTTPS only). The value from tfvars will be ignored.
- `service_url` - (Optional) The backend service URL for the API.
- `description` - (Optional) Description of the API.
- `subscription_required` - (Optional) Whether a subscription key is required to access the API. Defaults to `true`.

Versioning:
- `api_version` - (Optional) The version identifier for the API.
- `api_version_set_name` - (Optional) The name of the API version set to associate with this API.
- `revision_description` - (Optional) Description of the API revision.

Import:
- `import` - (Optional) Import configuration for OpenAPI, WSDL, WADL specifications.
  - `content_format` - (Required) Format of the content. Valid values: `openapi`, `openapi+json`, `openapi+json-link`, `openapi-link`, `swagger-json`, `swagger-link-json`, `wadl-link-json`, `wadl-xml`, `wsdl`, `wsdl-link`.
  - `content_value` - (Required) The API definition content or URL.
  - `wsdl_selector` - (Optional) WSDL selector for SOAP APIs.

Operations:
- `operations` - (Optional) Map of API operations. Each operation defines an HTTP method and URL template.

Policies:
- `policy` - (Optional) API-level policy configuration.
  - `xml_content` - (Optional) XML policy content.
  - `xml_link` - (Optional) URL to XML policy content.

Example:
```terraform
apis = {
  "petstore-api" = {
    display_name = "Petstore API"
    path         = "petstore"
    service_url  = "https://petstore.swagger.io/v2"

    operations = {
      "get-pets" = {
        display_name = "Get all pets"
        method       = "GET"
        url_template = "/pets"
      }
    }
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.apis :
      can(regex("^[^*#&+:<>?]+$", v.path))
    ])
    error_message = "API path cannot contain the following characters: *, #, &, +, :, <, >, ?."
  }
  # validation {
  #   condition = alltrue([
  #     for k, v in var.apis :
  #     alltrue([
  #       for protocol in v.protocols :
  #       contains(["http", "https", "ws", "wss"], protocol)
  #     ])
  #   ])
  #   error_message = "API protocols must be one of: http, https, ws, wss."
  # }
  validation {
    condition = alltrue(flatten([
      for k, v in var.apis : [
        for operation_key, operation_value in v.operations :
        contains(["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE"], operation_value.method)
      ]
    ]))
    error_message = "API operation method must be one of: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE."
  }
}



# Naming module inputs (required by scb_naming_module)
variable "env" {
  type        = string
  description = "(Required) environment code (e.g., test, prod)."
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit (AU) code."
}

variable "owner" {
  type        = string
  description = "(Required) technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation (e.g., rg, apim)."
}

variable "product_version" {
  type        = string
  description = "(Required) scb product version. Example: 1.0.0."
  default     = "1.0.0.0"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code."
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code."
}

variable "org" {
  type        = string
  description = "(Optional) company/business unit code."
  default     = "scb"
}

variable "region_code" {
  type        = string
  description = "(Optional) region code (e.g., sg, myw)."
  default     = "sg"
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
  description = "(Optional) base name used by naming module."
  default     = null
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) Remove dashes from generated name."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) Add random suffix to generated name."
  default     = false
}

variable "max_length" {
  type        = number
  description = "(Optional) Maximum length of generated name."
  default     = 80
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Length of random suffix."
  default     = 2
}


# Mandatory tags
variable "environment" {
  type = string
}

variable "business_owner" {
  type = string
}

variable "business_unit" {
  type = string
}

variable "criticality" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "data_classification" {
  type = string
}

variable "compliance" {
  type = string
}

# Optional tags
variable "region" {
  type    = string
  default = ""
}

variable "description" {
  type    = string
  default = ""
}

variable "notification_emails" {
  type    = list(string)
  default = []
}

variable "service" {
  type    = string
  default = "apim"
}

variable "app_name" {
  type    = string
  default = ""
}

variable "budget_id" {
  type    = string
  default = ""
}

variable "status" {
  type    = string
  default = ""
}

variable "app_support" {
  type    = string
  default = ""
}

variable "type" {
  type    = string
  default = ""
}

variable "cost_allocation_unit" {
  type    = string
  default = ""
}

variable "budget_limit" {
  type    = string
  default = ""
}

variable "cost_alert_threshold" {
  type    = string
  default = ""
}

variable "compliance_required" {
  type    = string
  default = ""
}

variable "delete_after" {
  type    = string
  default = ""
}

variable "tier" {
  type    = string
  default = ""
}

variable "app_id" {
  type    = string
  default = ""
}

variable "auto_delete" {
  type    = string
  default = ""
}

variable "auto_shutdown" {
  type    = string
  default = ""
}

variable "backup_policy" {
  type    = string
  default = ""
}

variable "disaster_recovery" {
  type    = string
  default = ""
}

variable "integration_id" {
  type    = string
  default = ""
}

variable "experiment_phase" {
  type    = string
  default = ""
}

variable "os" {
  type    = string
  default = ""
}

variable "last_vm_accessed" {
  type    = string
  default = ""
}

variable "maintenance_window" {
  type    = string
  default = ""
}

variable "patch_policy" {
  type    = string
  default = ""
}

variable "retention" {
  type    = string
  default = ""
}

variable "sandbox_type" {
  type    = string
  default = ""
}

# Policy / auth variables used when rendering central policy templates
variable "openid_config_url" {
  type        = string
  description = "OpenID Connect configuration URL"
  default     = ""
}

variable "audience" {
  type        = string
  description = "JWT audience for validate-jwt policy"
  default     = ""
}

variable "issuer" {
  type        = string
  description = "JWT issuer for validate-jwt policy"
  default     = ""
}

variable "origin1" {
  type        = string
  description = "CORS origin 1"
  default     = "*"
}

variable "origin2" {
  type        = string
  description = "CORS origin 2"
  default     = ""
}

variable "rate_calls" {
  type        = number
  description = "Rate limit calls"
  default     = 100
}

variable "rate_period_seconds" {
  type        = number
  description = "Rate limit window seconds"
  default     = 60
}

variable "quota_calls" {
  type        = number
  description = "Quota calls"
  default     = 1000
}

variable "quota_period_seconds" {
  type        = number
  description = "Quota window seconds"
  default     = 86400
}

variable "timeoutSeconds" {
  type        = number
  description = "Backend timeout seconds used in policies"
  default     = 30
}



# //Naming module Variables
# # -
# # Required Variables for Naming
# # -
# variable "env" {
#   type        = string
#   description = "(Required) <CN> environment code. Example: `test`. <br></br>&#8226; Value of `env` must be one of: `[nonprod,prod,core,int,uat,stage,dev,test,p,np]`."
# }

# variable "au" {
#   type        = string
#   description = "(Required) <CN> Accounting Unit (AU) code. Example: `0233985`. <br></br>&#8226; Value of `au` must be of numeric characters."
#   validation {
#     condition     = can(regex("^[[:digit:]]+$", var.au))
#     error_message = "Value for \"au\" must be of numeric characters."
#   }
# }

# variable "owner" {
#   type        = string
#   description = "(Required) <CN> technology owner group."
# }

# variable "resource_type_code" {
#   type        = string
#   description = "(Required) Azure resource type abbreviation (or `service` in <CN> Naming Standard). Example: `rg`, `vnet`, `st`, etc. More information: [Azure resource abbreviations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)"
# }

# variable "product_version" {
#   type        = string
#   description = "(Required) scb product version. Example: `1.0.0`."
# }

# variable "app_code" {
#   type        = string
#   description = "(Required) Application code. Example: network, mgmt, buil"
# }

# variable "bu" {
#   type        = string
#   description = "(Required) Bussiness unit code. Example: IT or scb."
# }

# # -
# # Optional Variables for Naming
# # -
# variable "org" {
#   type        = string
#   description = "(Optional) <CN> company/businness unit code. Example: `scb`."
#   default     = "scb"
# }

# variable "region_code" {
#   type        = string
#   description = "(Optional) scb region code.<br></br>&#8226; Value of `region_code` must be one of: `[sea,ea,eu,sg]`."
#   validation {
#     condition     = contains(["ea", "sea", "eu", "myw", "sg"], var.region_code)
#     error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg]."
#   }
#   default = "sa"
# }

# variable "additional_name" {
#   type        = string
#   description = "(Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated\" suffix. Example: `lan1`."
#   default     = null
# }

# variable "iterator" {
#   type        = string
#   description = "(Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated + additional_name\" concatenation. Example: `001`."
#   default     = null
# }

# variable "additional_tags" {
#   description = "(Optional) Additional base tags."
#   type        = map(string)
#   default     = null
# }

# variable "base_name" {
#   type        = string
#   description = "(optional) Application/Infrastructure \"base\" name. Example: `aks`."
#   default     = null
# }

# # -
# # - Optional tuning switches & defaults
# # -
# variable "no_dashes" {
#   type        = bool
#   description = "(Optional) When set to `true`, it will remove all `'-'` separators from the generated name."
#   default     = false
# }

# variable "add_random" {
#   type        = bool
#   description = "(Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end."
#   default     = false
# }

# variable "max_length" {
#   type        = number
#   description = "(Optional) Set the maximum length of the generated name. If over, the name will be trimmed to the `max_length`, considering the eventual `random_number` suffix. See this link for reference: [Resource name rules](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)"
#   default     = 80
# }

# variable "rnd_length" {
#   type        = number
#   description = "(Optional) Set the length of the `random_number` generated."
#   default     = 2
# }

# # -
# # Mandatory Tags - Only the required 8 tags as per specification
# # -
# variable "environment" {
#   type        = string
#   description = "(Required) Environment where the resource is located."
# }

# variable "business_owner" {
#   type        = string
#   description = "(Required) Contact name of the application owner."
# }

# variable "business_unit" {
#   type        = string
#   description = "(Required) Department that owns the resources."
# }

# variable "criticality" {
#   type        = string
#   description = "(Required) Workload SLA requirements."
# }

# variable "cost_center" {
#   type        = string
#   description = "(Required) Cost center that should bear the costs."
# }

# variable "data_classification" {
#   type        = string
#   description = "(Required) Data classification level."
# }

# variable "compliance" {
#   type        = string
#   description = "(Required) Specific standard/regulation."
# }

# # -
# # Optional Tags - Only the required 3 optional tags as per specification
# # -
# variable "region" {
#   type        = string
#   description = "(Optional) Cloud region where resource is deployed."
#   default     = ""
# }

# variable "description" {
#   type        = string
#   description = "(Optional) Brief description of the resource purpose."
#   default     = ""
# }

# variable "notification_emails" {
#   type        = list(string)
#   description = "(Optional) List of email addresses for notifications."
#   default     = []
# }

# variable "compliance_required" {
#   type        = string
#   description = "(Required) Does resource need to comply with standards?"
#   default     = "No"
# }
