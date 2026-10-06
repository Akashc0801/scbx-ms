#
# Copyright 2023 BBL & Microsoft. All rights reserved.
#

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
