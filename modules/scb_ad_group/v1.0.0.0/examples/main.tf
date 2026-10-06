module "scb-ad-group" {
  source = "../"

  for_each = var.ad_groups

  type                    = each.value.type
  tier                    = each.value.tier
  scope                   = each.value.scope
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