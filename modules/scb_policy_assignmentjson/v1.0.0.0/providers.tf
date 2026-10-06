# -
# - Required Terraform providers & versions
# -
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.89.0"
    }
  }
}
