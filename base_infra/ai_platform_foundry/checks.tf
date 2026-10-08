# Plan-time guards. They fail the plan instead of creating resources with
# invalid names or in a subnet Foundry cannot use.
#
# scb_naming_module/v1.0.0.1 does not apply max_length unless add_random is
# true, so a long name is passed to Azure as-is. azurerm rejects some of them
# at plan; azapi resources (Foundry) would only fail at apply.
locals {
  name_length_limits = {
    key_vault          = 24
    storage_account    = 24
    container_registry = 50
    ai_search          = 60
    foundry            = 64
  }
}

resource "terraform_data" "preflight" {
  lifecycle {
    precondition {
      condition     = alltrue([for k, limit in local.name_length_limits : length(local.expected_names[k]) <= limit])
      error_message = "Generated names exceed Azure limits: ${join(", ", [for k, limit in local.name_length_limits : "${k} '${local.expected_names[k]}' (${length(local.expected_names[k])}/${limit})" if length(local.expected_names[k]) > limit])}. Shorten app_code or base_name for these resources."
    }
    precondition {
      condition     = module.key_vault.name == local.expected_names.key_vault && module.storage_account.name == local.expected_names.storage_account && module.container_registry.name == local.expected_names.container_registry && module.ai_search.resource.name == local.expected_names.ai_search
      error_message = "A module generated a different name than expected (check no_dashes and resource_type_code)."
    }
    precondition {
      condition     = endswith(local.foundry_account_id, "/${local.expected_names.foundry}")
      error_message = "Foundry account name does not match '${local.expected_names.foundry}'."
    }
    precondition {
      condition     = contains([for d in try(data.azapi_resource.agent_subnet.output.properties.delegations, []) : d.properties.serviceName], "Microsoft.App/environments")
      error_message = "Agent subnet '${var.network.agent_subnet_name}' must be delegated to Microsoft.App/environments before Foundry network injection. Add the delegation in base_infra/ai_platform_network."
    }
    precondition {
      condition     = alltrue([for p in var.foundry.projects : contains(keys(var.user_assigned_identities), p.identity_key)]) && contains(keys(var.user_assigned_identities), var.foundry.identity_key)
      error_message = "foundry.identity_key and every foundry.projects[*].identity_key must be a key of user_assigned_identities."
    }
  }
}
