# Variables for the example
variable "resource_group_name" {
  description = "Name of the resource group for examples"
  type        = string
  default     = "rg-aks-security-example"
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

variable "enable_management_group_example" {
  description = "Enable management group remediation example (requires appropriate permissions)"
  type        = bool
  default     = false
}