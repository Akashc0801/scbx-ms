terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.46, < 4.0"
    }
  }
}
