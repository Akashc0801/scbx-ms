terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
}

## Section to provide a random Azure region for the resource group
# This avoids external module sources to satisfy CKV_TF_1 in CI scans.
locals {
  available_regions = [
    "southeastasia",
    "eastus",
    "westeurope",
    "uksouth",
    "australiaeast"
  ]
  azure_region        = var.azure_region != null ? var.azure_region : local.available_regions[random_integer.region_index.result]
  generated_name      = "apim-${random_string.name_suffix.result}"
  resource_group_name = "${var.resource_group_name_prefix}-${random_string.name_suffix.result}"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.available_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.azure_region
  name     = local.resource_group_name
}

# This is the module call
module "apim" {
  source = "../../"
  #checkov:skip=CKV_AZURE_174: Public access can be intentionally enabled via module input for supported deployment scenarios.

  # Required naming and tagging inputs from main module
  env            = "prod"
  au             = "00121"
  owner          = "CEAT"
  app_code       = "mgmt"
  bu             = "it"
  app_name       = "API Management Platform"
  business_unit  = "GTD-ISD"
  business_owner = "Head of Cloud Engineering and Automation"
  budget_id      = "83254"
  criticality    = "T1"
  environment    = "Prod"
  service        = "apim"

  location            = azurerm_resource_group.this.location
  name                = local.generated_name
  publisher_email     = "admin@contoso.com"
  resource_group_name = azurerm_resource_group.this.name
  # =================================================================
  # APIs with Operations Configuration
  # =================================================================
  apis = {
    # Simple Echo API for testing
    "echo-api" = {
      display_name          = "Echo API"
      path                  = "echo"
      protocols             = ["https"]
      revision              = "1"
      description           = "Simple echo API for testing - returns request information"
      subscription_required = true
      service_url           = "http://echoapi.cloudapp.net/api"

      # API-Level Policy - applies to all operations in this API
      policy = {
        xml_content = <<-XML
<policies>
  <inbound>
    <base />
    <rate-limit calls="100" renewal-period="60" />
    <set-header name="X-API-Name" exists-action="override">
      <value>Echo API</value>
    </set-header>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      # Single operation to demonstrate API operation creation
      operations = {
        "get-resource" = {
          display_name = "Get Resource"
          method       = "GET"
          url_template = "/resource"
          description  = "Echo back request information"

          responses = [
            {
              status_code = 200
              description = "Success - returns request echo"
              representations = [
                {
                  content_type = "application/json"
                }
              ]
            }
          ]
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  # Enable managed identity (optional - useful for accessing other Azure resources)
  managed_identities = {
    system_assigned = true
  }
  # =================================================================
  # Named Values Configuration
  # Named values are like environment variables - can be referenced in policies
  # =================================================================
  named_values = {
    # Plain text configuration value
    "backend-url" = {
      display_name = "Backend-URL"
      value        = "http://echoapi.cloudapp.net/api"
      tags         = ["configuration", "url"]
    }

    # Secret value (encrypted at rest in APIM)
    "api-key" = {
      display_name = "API-Key"
      value        = "secret-key-value-12345"
      secret       = true
      tags         = ["secret", "api"]
    }

    # Environment indicator
    "environment" = {
      display_name = "Environment"
      value        = "development"
      tags         = ["environment"]
    }
  }
  # =================================================================
  # Products Configuration
  # Products package APIs with policies and access control
  # =================================================================
  products = {
    "starter" = {
      display_name          = "Starter"
      description           = "Basic API access for developers"
      subscription_required = true
      approval_required     = false
      state                 = "published"
      terms                 = "By subscribing to this product, you agree to our terms of service."
      api_names             = ["echo-api"] # Link API to this product
      group_names           = ["developers"]
    }

    "premium" = {
      display_name          = "Premium"
      description           = "Premium access with higher rate limits - requires approval"
      subscription_required = true
      approval_required     = true
      subscriptions_limit   = 10
      state                 = "published"
      api_names             = ["echo-api"] # Same API, different product tier
      group_names           = ["developers", "guests"]
    }
  }
  publisher_name = "Contoso"
  sku_name       = "Developer_1"
  # =================================================================
  # Subscriptions Configuration
  # Subscriptions provide access keys for consuming products/APIs
  # =================================================================
  subscriptions = {
    "starter-subscription" = {
      display_name     = "Starter Subscription"
      scope_type       = "product"
      scope_identifier = "starter"
      state            = "active"
      allow_tracing    = true
    }

    "premium-subscription" = {
      display_name     = "Premium Subscription"
      scope_type       = "product"
      scope_identifier = "premium"
      state            = "submitted" # Awaiting approval (because premium requires approval)
      allow_tracing    = true
    }
  }
}
