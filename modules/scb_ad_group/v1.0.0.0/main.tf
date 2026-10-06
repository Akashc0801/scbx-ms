resource "azuread_group" "scb-ad-group" {
  display_name            = join("-", compact([var.type, var.tier, var.scope, var.bu_code, var.app_code, var.rolecode, var.function, var.env, var.region]))
  administrative_unit_ids = var.administrative_unit_ids
  assignable_to_role      = var.assignable_to_role
  description             = var.description != "" ? var.description : null
  members                 = var.members
  security_enabled        = var.security_enabled
  owners                  = setunion(var.owners, [data.azuread_client_config.current.object_id])
  prevent_duplicate_names = var.prevent_duplicate_names
  visibility              = var.visibility
}