variable "subscription_id" {
  type        = string
  description = "Subscription that hosts the Terraform state backend."
  default     = "3471ad5a-d8a8-4a80-b30b-668798733c14"
}

variable "location" {
  type        = string
  description = "Azure region for the Terraform state resources."
  default     = "southeastasia"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group containing the Terraform state backend."
  default     = "rg-scbx-terraform-state"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique Storage account name for Terraform state."
  default     = "stscbxtf3471ad5a"
}

variable "container_name" {
  type        = string
  description = "Blob container used for Terraform state."
  default     = "tfstate"
}
