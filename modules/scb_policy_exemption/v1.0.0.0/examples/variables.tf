variable "resource_group_name" {
  description = "Name of the resource group for examples"
  type        = string
  default     = "rg-policy-exemption-example"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
  default     = "Example"
}
