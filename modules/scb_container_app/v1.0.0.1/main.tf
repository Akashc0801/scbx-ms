# -
# - Naming Module
# -
module "scb_module_ca" {
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

  # Mandatory Business Tags
  business_unit  = var.business_unit
  business_owner = var.business_owner

  # Mandatory DevOps Tags
  product_version = var.product_version

  # Mandatory Finance Tags
  cost_center = var.cost_center

  # Mandatory Governance Tags
  data_classification = var.data_classification
  compliance_required = var.compliance_required
  compliance          = var.compliance

  # Mandatory Operation Tags
  criticality = var.criticality
  environment = var.environment

  # Optional Tags
  description         = var.description
  notification_emails = var.notification_emails
  region              = var.region

  # Additional custom tags
  additional_tags = var.additional_tags
}

resource "time_sleep" "cae_rbac_wait_on_cr" {
  count           = var.create_container_app_environment ? 1 : 0
  create_duration = "180s"
  depends_on      = [azurerm_role_assignment.rbac_cae]
}

# -
# - Container App
# -
resource "azurerm_container_app" "this" {
  name                         = module.scb_module_ca.name
  container_app_environment_id = var.create_container_app_environment ? azurerm_container_app_environment.ca_env[0].id : data.azurerm_container_app_environment.ace_existing[0].id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = module.scb_module_ca.tags
  workload_profile_name        = var.workload_profile_name != null ? var.workload_profile_name : null
  max_inactive_revisions       = var.max_inactive_revisions != null ? var.max_inactive_revisions : null

  template {
    min_replicas    = var.template.min_replicas
    max_replicas    = var.template.max_replicas
    revision_suffix = var.template.revision_suffix

    dynamic "container" {
      for_each = var.template.containers

      content {
        cpu     = container.value.cpu
        image   = container.value.image
        memory  = container.value.memory
        name    = container.value.name
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env != null ? container.value.env : []

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }

        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe != null ? container.value.liveness_probe : []

          content {
            failure_count_threshold = liveness_probe.value.failure_count_threshold
            host                    = liveness_probe.value.host
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            path                    = liveness_probe.value.path
            port                    = liveness_probe.value.port
            timeout                 = liveness_probe.value.timeout
            transport               = liveness_probe.value.transport

            dynamic "header" {
              for_each = liveness_probe.value.header != null ? liveness_probe.value.header : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe != null ? container.value.readiness_probe : []

          content {
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            host                    = readiness_probe.value.host
            initial_delay           = readiness_probe.value.initial_delay
            interval_seconds        = readiness_probe.value.interval_seconds
            path                    = readiness_probe.value.path
            port                    = readiness_probe.value.port
            success_count_threshold = readiness_probe.value.success_count_threshold
            timeout                 = readiness_probe.value.timeout
            transport               = readiness_probe.value.transport

            dynamic "header" {
              for_each = readiness_probe.value.header != null ? readiness_probe.value.header : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = container.value.startup_probe != null ? container.value.startup_probe : []

          content {
            failure_count_threshold = startup_probe.value.failure_count_threshold
            host                    = startup_probe.value.host
            initial_delay           = startup_probe.value.initial_delay
            interval_seconds        = startup_probe.value.interval_seconds
            path                    = startup_probe.value.path
            port                    = startup_probe.value.port
            timeout                 = startup_probe.value.timeout
            transport               = startup_probe.value.transport

            dynamic "header" {
              for_each = startup_probe.value.header != null ? startup_probe.value.header : []

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts != null ? container.value.volume_mounts : []

          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = var.template.init_container != null ? var.template.init_container : []

      content {
        cpu     = init_container.value.cpu
        image   = init_container.value.image
        memory  = init_container.value.memory
        name    = init_container.value.name
        args    = init_container.value.args
        command = init_container.value.command

        dynamic "env" {
          for_each = init_container.value.env != null ? init_container.value.env : []

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts != null ? init_container.value.volume_mounts : []

          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = var.template.azure_queue_scale_rule != null ? var.template.azure_queue_scale_rule : []

      content {
        name         = azure_queue_scale_rule.value.name
        queue_length = azure_queue_scale_rule.value.queue_length
        queue_name   = azure_queue_scale_rule.value.queue_name

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.template.custom_scale_rule != null ? var.template.custom_scale_rule : []

      content {
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata
        name             = custom_scale_rule.value.name

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication != null ? custom_scale_rule.value.authentication : []

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.template.http_scale_rule != null ? var.template.http_scale_rule : []

      content {
        concurrent_requests = http_scale_rule.value.concurrent_requests
        name                = http_scale_rule.value.name

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication != null ? http_scale_rule.value.authentication : []

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = var.template.tcp_scale_rule != null ? var.template.tcp_scale_rule : []

      content {
        concurrent_requests = tcp_scale_rule.value.concurrent_requests
        name                = tcp_scale_rule.value.name

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication != null ? tcp_scale_rule.value.authentication : []

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "volume" {
      for_each = var.template.volume != null ? var.template.volume : []

      content {
        name         = volume.value.name
        storage_name = volume.value.storage_name
        storage_type = volume.value.storage_type
      }
    }
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? { this = var.ingress } : {}

    content {
      allow_insecure_connections = ingress.value.allow_insecure_connections
      client_certificate_mode    = ingress.value.client_certificate_mode
      exposed_port               = ingress.value.exposed_port
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight

        content {
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
          percentage      = traffic_weight.value.percentage
        }
      }

      dynamic "custom_domain" {
        for_each = ingress.value.custom_domain != null ? { this = ingress.value.custom_domain } : {}

        content {
          certificate_binding_type = custom_domain.value.certificate_binding_type
          certificate_id           = custom_domain.value.certificate_id
          name                     = custom_domain.value.name
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restriction != null ? ingress.value.ip_security_restriction : []

        content {
          action           = ip_security_restriction.value.action
          description      = ip_security_restriction.value.description
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
        }
      }
    }
  }

  dynamic "dapr" {
    for_each = var.dapr != null ? { this = var.dapr } : {}

    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  dynamic "registry" {
    for_each = var.registries != null ? var.registries : []

    content {
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      server               = registry.value.server
      username             = registry.value.username
    }
  }

  dynamic "secret" {
    for_each = var.secrets != null ? {
      for secret in var.secrets : secret.name => secret
    } : {}

    content {
      name                = each.value.name
      value               = each.value.value
      identity            = each.value.identity
      key_vault_secret_id = each.value.key_vault_secret_id
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != null ? { this = local.identity_type } : {}

    content {
      type         = identity.value
      identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    }
  }

  depends_on = [time_sleep.cae_rbac_wait_on_cr]
}

# -
# - Management Lock
# -
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${module.scb_module_ca.name}")
  scope      = azurerm_container_app.this.id
}

# -
# - Role Assignments
# -
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_container_app.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
