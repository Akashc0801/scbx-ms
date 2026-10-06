variable "ad_groups" {
  description = "A map of AD groups to create. The key is used as the unique identifier for each group and should be a descriptive name. The value is an object containing the properties for each group."
  type = map(object({
    type                    = string
    tier                    = string
    scope                   = string
    rolecode                = string
    function                = string
    env                     = string
    region                  = string
    administrative_unit_ids = optional(set(string))
    assignable_to_role      = optional(bool)
    description             = optional(string)
    members                 = optional(set(string))
    security_enabled        = bool
    owners                  = optional(set(string))
    prevent_duplicate_names = bool
    visibility              = optional(string)
  }))
}

variable "subscription_id" {
  description = "The subscription ID to use for the AzureRM provider."
  type        = string
}