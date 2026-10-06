module "scb_module_apim" {
  source = "../../scb_naming_module/v1.0.0.1"

  # Basic naming parameters
  env                = var.env
  org                = var.org
  region_code        = var.region_code
  base_name          = var.base_name
  additional_name    = var.additional_name
  iterator           = var.iterator
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = var.resource_type_code
  max_length         = var.max_length
  no_dashes          = var.no_dashes
  add_random         = var.add_random
  rnd_length         = var.rnd_length

  # Use v1.0.0.1 naming module interface
  product_version = "1.0.0.1"

  # Pass mandatory tags to naming module (8 mandatory tags)
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # Pass optional tags to naming module (3 optional tags)
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails

  # Additional custom tags with ProductName and ProductVersion
  additional_tags = merge(
    var.additional_tags != null ? var.additional_tags : {},
    {
      Owner              = var.owner
      AppName            = var.app_name
      BudgetID           = var.budget_id
      Status             = var.status
      ProductName        = "scb_apim_api"
      ProductVersion     = "1.0.0.0"
      Service            = var.service
      AppSupport         = var.app_support
      Type               = var.type
      CostAllocationUnit = var.cost_allocation_unit
      BudgetLimit        = var.budget_limit
      CostAlertThreshold = var.cost_alert_threshold
      ComplianceRequired = var.compliance_required
    },
    var.delete_after != "" ? { DeleteAfter = var.delete_after } : {},
    var.tier != "" ? { Tier = var.tier } : {},
    var.app_id != "" ? { AppId = var.app_id } : {},
    var.auto_delete != "" ? { AutoDelete = var.auto_delete } : {},
    var.auto_shutdown != "" ? { AutoShutdown = var.auto_shutdown } : {},
    var.backup_policy != "" ? { BackupPolicy = var.backup_policy } : {},
    var.disaster_recovery != "" ? { DisasterRecovery = var.disaster_recovery } : {},
    var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.os != "" ? { OS = var.os } : {},
    var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {},
    var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {}
  )
}

# API Version Sets (required for versioned APIs)
resource "azurerm_api_management_api_version_set" "this" {
  for_each = var.api_version_sets

  api_management_name = var.apim_name
  display_name        = each.value.display_name
  name                = each.key
  resource_group_name = var.resource_group_name
  versioning_scheme   = each.value.versioning_scheme
  description         = each.value.description
  version_header_name = each.value.version_header_name
  version_query_name  = each.value.version_query_name


}

# APIs - Core API definitions
resource "azurerm_api_management_api" "this" {
  for_each = var.apis

  api_management_name  = var.apim_name
  name                 = each.key
  resource_group_name  = var.resource_group_name
  revision             = each.value.revision
  description          = each.value.description
  display_name         = each.value.display_name
  path                 = each.value.path
  protocols            = ["https"] # Enforced by module security baseline - HTTPS only
  revision_description = each.value.revision_description
  service_url          = each.value.service_url
  # Source API (for cloning)
  source_api_id         = each.value.source_api_id
  subscription_required = each.value.subscription_required
  terms_of_service_url  = each.value.terms_of_service_url
  # API versioning
  version        = each.value.api_version
  version_set_id = each.value.api_version_set_name != null ? azurerm_api_management_api_version_set.this[each.value.api_version_set_name].id : null

  # Contact information
  dynamic "contact" {
    for_each = each.value.contact != null ? [each.value.contact] : []

    content {
      email = contact.value.email
      name  = contact.value.name
      url   = contact.value.url
    }
  }
  # Import configuration for OpenAPI, WSDL, WADL
  dynamic "import" {
    for_each = each.value.import != null ? [each.value.import] : []

    content {
      content_format = import.value.content_format
      content_value  = import.value.content_value

      dynamic "wsdl_selector" {
        for_each = import.value.wsdl_selector != null ? [import.value.wsdl_selector] : []

        content {
          endpoint_name = wsdl_selector.value.endpoint_name
          service_name  = wsdl_selector.value.service_name
        }
      }
    }
  }
  # License information
  dynamic "license" {
    for_each = each.value.license != null ? [each.value.license] : []

    content {
      name = license.value.name
      url  = license.value.url
    }
  }
  # OAuth2 Authorization
  dynamic "oauth2_authorization" {
    for_each = each.value.oauth2_authorization != null ? [each.value.oauth2_authorization] : []

    content {
      authorization_server_name = oauth2_authorization.value.authorization_server_name
      scope                     = oauth2_authorization.value.scope
    }
  }
  # OpenID Connect Authentication
  dynamic "openid_authentication" {
    for_each = each.value.openid_authentication != null ? [each.value.openid_authentication] : []

    content {
      openid_provider_name         = openid_authentication.value.openid_provider_name
      bearer_token_sending_methods = openid_authentication.value.bearer_token_sending_methods
    }
  }
  # Subscription Key Configuration
  dynamic "subscription_key_parameter_names" {
    for_each = each.value.subscription_key_parameter_names != null ? [each.value.subscription_key_parameter_names] : []

    content {
      header = subscription_key_parameter_names.value.header
      query  = subscription_key_parameter_names.value.query
    }
  }

  depends_on = [
    azurerm_api_management_api_version_set.this
  ]
}

#################################################
# API Operations
#################################################

resource "azurerm_api_management_api_operation" "this" {
  for_each = local.api_operations

  operation_id        = each.key
  api_name            = azurerm_api_management_api.this[each.value.api_key].name
  api_management_name = var.apim_name
  resource_group_name = var.resource_group_name
  display_name        = each.value.display_name
  method              = each.value.method
  url_template        = each.value.url_template
  # description         = lookup(each.value, "description", null)
  description = each.value.description

  dynamic "request" {
    for_each = each.value.request != null ? [each.value.request] : []

    content {
      description = request.value.description

      dynamic "header" {
        for_each = request.value.headers != null ? request.value.headers : []

        content {
          name          = header.value.name
          required      = header.value.required
          type          = header.value.type
          default_value = header.value.default_value
          description   = header.value.description
          values        = header.value.values
        }
      }
      dynamic "query_parameter" {
        for_each = request.value.query_parameters != null ? request.value.query_parameters : []

        content {
          name          = query_parameter.value.name
          required      = query_parameter.value.required
          type          = query_parameter.value.type
          default_value = query_parameter.value.default_value
          description   = query_parameter.value.description
          values        = query_parameter.value.values
        }
      }
      dynamic "representation" {
        for_each = request.value.representations != null ? request.value.representations : []

        content {
          content_type = representation.value.content_type
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name

          dynamic "form_parameter" {
            for_each = representation.value.form_parameters != null ? representation.value.form_parameters : []

            content {
              name          = form_parameter.value.name
              required      = form_parameter.value.required
              type          = form_parameter.value.type
              default_value = form_parameter.value.default_value
              description   = form_parameter.value.description
              values        = form_parameter.value.values
            }
          }
        }
      }
    }
  }
  # Response configuration
  dynamic "response" {
    for_each = each.value.responses != null ? each.value.responses : []

    content {
      status_code = response.value.status_code
      description = response.value.description

      dynamic "header" {
        for_each = response.value.headers != null ? response.value.headers : []

        content {
          name          = header.value.name
          required      = header.value.required
          type          = header.value.type
          default_value = header.value.default_value
          description   = header.value.description
          values        = header.value.values
        }
      }
      dynamic "representation" {
        for_each = response.value.representations != null ? response.value.representations : []

        content {
          content_type = representation.value.content_type
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name

          dynamic "form_parameter" {
            for_each = representation.value.form_parameters != null ? representation.value.form_parameters : []

            content {
              name          = form_parameter.value.name
              required      = form_parameter.value.required
              type          = form_parameter.value.type
              default_value = form_parameter.value.default_value
              description   = form_parameter.value.description
              values        = form_parameter.value.values
            }
          }
        }
      }
    }
  }
  # Template parameters (URL path parameters)
  dynamic "template_parameter" {
    # for_each = coalesce(each.value.template_parameters, [])
    # content {
    #   name          = template_parameter.value.name
    #   required      = lookup(template_parameter.value, "required", null)
    #   type          = lookup(template_parameter.value, "type", null)
    #   default_value = lookup(template_parameter.value, "default_value", null)
    #   description   = lookup(template_parameter.value, "description", null)
    #   values        = lookup(template_parameter.value, "values", null)
    # }
    for_each = each.value.template_parameters != null ? each.value.template_parameters : []

    content {
      name          = template_parameter.value.name
      required      = template_parameter.value.required
      type          = template_parameter.value.type
      default_value = template_parameter.value.default_value
      description   = template_parameter.value.description
      values        = template_parameter.value.values
    }
  }
}

#################################################
# API-Level Policies
#################################################

resource "azurerm_api_management_api_policy" "this" {
  for_each = {
    for k, v in var.apis :
    k => v if lookup(v, "policy", null) != null
  }

  api_management_name = var.apim_name
  api_name            = azurerm_api_management_api.this[each.key].name
  resource_group_name = var.resource_group_name
  xml_content = (
    lookup(each.value.policy, "policy_template", null) != null ? templatefile(each.value.policy.policy_template,
      lookup(each.value.policy, "policy_vars", {})
    )
    : lookup(each.value.policy, "xml_content", null)
  )
  xml_link = lookup(each.value.policy, "xml_link", null)
  # xml_content = lookup(each.value, "policy_template", null) != null ? templatefile(each.value.policy_template,
  # lookup(each.value, "policy_vars", {})) : lookup(each.value, "xml_content", null)
}

#################################################
# Operation-Level Policies
#################################################

resource "azurerm_api_management_api_operation_policy" "this" {
  for_each = local.operation_policies

  api_management_name = var.apim_name
  api_name            = azurerm_api_management_api.this[each.value.api_key].name
  operation_id        = azurerm_api_management_api_operation.this[each.key].operation_id
  resource_group_name = var.resource_group_name
  xml_content = (
    lookup(each.value.policy, "policy_template", null) != null
    ? templatefile(
      each.value.policy.policy_template,
      lookup(each.value.policy, "policy_vars", {})
    )
    : lookup(each.value.policy, "xml_content", null)
  )
  xml_link = lookup(each.value.policy, "xml_link", null)

  # xml_content = each.value.policy_template != null ? templatefile(each.value.policy_template, lookup(each.value, "policy_vars", {})) : lookup(each.value, "xml_content", null)
  depends_on = [
    azurerm_api_management_api.this,
    azurerm_api_management_api_operation.this
  ]
}










































































# #############################################
# # API Version Sets (Optional)
# #############################################

# resource "azurerm_api_management_api_version_set" "this" {
#   for_each = var.api_version_sets

#   name         = each.key
#   display_name = each.value.display_name
#   # api_management_name = data.azurerm_api_management.existing.name
#   api_management_name = var.apim_name
#   resource_group_name = var.resource_group_name
#   versioning_scheme   = each.value.versioning_scheme
#   # description         = each.value.description
#   # version_header_name = each.value.version_header_name
#   # version_query_name  = each.value.version_query_name

#   # resource_group_name = azurerm_api_management.this.resource_group_name


#   # depends_on = [azurerm_api_management.this]
# }

# #############################################
# # APIs
# #############################################

# resource "azurerm_api_management_api" "this" {
#   for_each = var.apis

#   name                = each.key
#   display_name        = each.value.display_name
#   resource_group_name = var.resource_group_name
#   api_management_name = var.apim_name

#   revision              = each.value.revision
#   path                  = each.value.path
#   protocols             = each.value.protocols
#   service_url           = each.value.service_url
#   subscription_required = each.value.subscription_required

#   version_set_id = each.value.api_version_set_name != null ? azurerm_api_management_api_version_set.this[each.value.api_version_set_name].id : null

#   dynamic "import" {
#     for_each = each.value.import != null ? [each.value.import] : []
#     content {
#       content_format = import.value.content_format
#       content_value  = import.value.content_value
#     }
#   }
# }

# #############################################
# # API Operations
# #############################################

# resource "azurerm_api_management_api_operation" "this" {
#   for_each = {
#     for op in local.api_operations :
#     "${op.api_key}-${op.op_key}" => op
#   }

#   api_management_name = var.apim_name
#   resource_group_name = var.resource_group_name
#   api_name            = azurerm_api_management_api.this[each.value.api_key].name

#   operation_id = each.value.op_key
#   display_name = each.value.config.display_name
#   method       = each.value.config.method
#   url_template = each.value.config.url_template
#   dynamic "template_parameter" {
#     for_each = each.value.config.template_parameters != null ? each.value.config.template_parameters : []
#     content {
#       name          = template_parameter.value.name
#       required      = lookup(template_parameter.value, "required", null)
#       type          = lookup(template_parameter.value, "type", null)
#       default_value = lookup(template_parameter.value, "default_value", null)
#       description   = lookup(template_parameter.value, "description", null)
#       values        = lookup(template_parameter.value, "values", null)
#     }
#   }
# }

# # Operation-level policies (if an operation supplies `policy` or `policy_template`)
# resource "azurerm_api_management_api_operation_policy" "this" {
#   for_each = {
#     for k, v in local.api_operations :
#     k => v if(v.config.policy != null || v.config.policy_template != null)
#   }

#   api_management_name = var.apim_name
#   resource_group_name = var.resource_group_name
#   api_name            = azurerm_api_management_api.this[each.value.api_key].name
#   operation_id        = each.value.op_key

#   xml_content = each.value.config.policy != null ? each.value.config.policy : templatefile(each.value.config.policy_template, {
#     openid_config_url = var.openid_config_url
#     audience          = var.audience
#     issuer            = var.issuer
#     origin1           = var.origin1
#     origin2           = var.origin2
#     calls             = var.rate_calls
#     periodSeconds     = var.rate_period_seconds
#     timeoutSeconds    = var.timeoutSeconds
#   })
# }
# #############################################
# # API Policies
# #############################################

# resource "azurerm_api_management_api_policy" "this" {
#   for_each = {
#     for k, v in var.apis :
#     k => v if(v.policy != null || v.policy_template != null)
#   }

#   api_management_name = var.apim_name
#   resource_group_name = var.resource_group_name
#   api_name            = azurerm_api_management_api.this[each.key].name

#   xml_content = each.value.policy != null ? each.value.policy : templatefile(each.value.policy_template, {
#     openid_config_url = var.openid_config_url
#     audience          = var.audience
#     issuer            = var.issuer
#     origin1           = var.origin1
#     origin2           = var.origin2
#     calls             = var.rate_calls
#     periodSeconds     = var.rate_period_seconds
#     timeoutSeconds    = var.timeoutSeconds
#   })
# }