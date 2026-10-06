#
# Copyright 2023 BBL & Microsoft. All rights reserved.
#

# -
# Required Variable
# -
variable "policyDefinitionJsonFile" {
  type        = string
  description = "(Required) Relative path of the Azure Policy Definition JSON file, under the root folder `policy_defintions/`."
}

# -
# Optional Variables
# -
variable "name" {
  type        = string
  description = "(Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `name`."
  default     = null
}
variable "display_name" {
  type        = string
  description = "(Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `display_name`."
  default     = null
}
variable "description" {
  type        = string
  description = "(Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `description`."
  default     = null
}
variable "mode" {
  type        = string
  description = "(Optional) If set or `not null`, this value will replace the value from the Policy Definition JSON for the policy definition `mode`."
  default     = null
}
variable "management_group_id" {
  type        = string
  description = "(Optional) The ID of the Management Group where this policy should be defined. If using `azurerm_management_group` block to set this variable, be sure to use `name` or `group_id`, but not `id`."
  default     = null
}
