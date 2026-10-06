# CIS Azure Foundations v3.0.0 Policy Set Assignment with Selective Audit Configuration
# This configuration assigns the CIS policy set with 53 policies but only enables 2 for auditing
# All other policies are disabled

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Get current subscription data
data "azurerm_subscription" "current" {}

# Policy Set Assignment for Selective CIS Compliance Auditing
module "cis_selective_audit_policy_set" {
  source = "../../"

  name         = "CIS-Selective-Audit-PolicySet"
  display_name = "CIS Azure Foundations v3.0.0 - Selective Audit"
  description  = "CIS Azure Foundations Benchmark v3.0.0 policy set with selective auditing - only 2 policies enabled for audit, rest disabled"

  # CIS Azure Foundations v3.0.0 policy set definition ID with 53 policies
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/470a962c-86a0-433b-803a-3c176b5ce79c"
  scope                = data.azurerm_subscription.current.id

  # Parameters to configure individual policies within the CIS policy set
  # Each policy has its own effect parameter in the format: effect-{policy-id}
  parameters = {
    # EXAMPLE: Enable 2 specific policies for auditing
    # Policy 1: Azure Defender for servers should be enabled
    "effect-4da35fc9-c9e7-4960-aec9-797fe7d9051d" = {
      "value" = "AuditIfNotExists"
    }

    # Policy 2: Key Vault keys should have an expiration date
    "effect-152b15f7-8e1f-4c1f-ab71-8c010ba5dbc0" = {
      "value" = "Audit"
    }

    # ALL OTHER POLICIES - Set to Disabled (you can customize which ones you want)
    # Azure Defender for Containers
    "effect-1c988dd6-ade4-430f-a608-2a3e5b0a6d38" = {
      "value" = "Disabled"
    }

    # Azure Defender for App Service
    "effect-2913021d-f2fd-4f3d-b958-22354e2bdbcb" = {
      "value" = "Disabled"
    }

    # Microsoft Defender for Azure Cosmos DB
    "effect-adbe85b5-83e6-4350-ab58-bf3a4f736e5e" = {
      "value" = "Disabled"
    }

    # Azure Defender for SQL Managed Instance
    "effect-0a9fbe0d-c5c4-4da8-87d8-f4fd77338835" = {
      "value" = "Disabled"
    }

    # Azure Defender for SQL servers on machines
    "effect-abfb7388-5bf4-4ad7-ba99-2cd2f41cebb9" = {
      "value" = "Disabled"
    }

    # Azure Defender for SQL servers
    "effect-6581d072-105e-4418-827f-bd446d56421b" = {
      "value" = "Disabled"
    }

    # Azure Defender for Key Vault
    "effect-0e6763cc-5078-4e64-889d-ff4d9a839047" = {
      "value" = "Disabled"
    }

    # Azure Defender for Resource Manager
    "effect-c3d20c29-b36d-48fe-808b-99a87530ad99" = {
      "value" = "Disabled"
    }

    # Email notification for high severity alerts
    "effect-6e2593d9-add6-4083-9c9b-4b7d2188c899" = {
      "value" = "Disabled"
    }

    # Key Vault secrets should have an expiration date
    "effect-98728c90-32c7-4049-8429-847dc0f4fe37" = {
      "value" = "Disabled"
    }

    # Key vaults should have soft delete enabled
    "effect-0b60c0b2-2dc2-4e1c-b5c9-abbed971de53" = {
      "value" = "Disabled"
    }

    "effect-1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d" = {
      "value" = "Disabled"
    }

    # Azure Key Vault should use RBAC permission model
    "effect-12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5" = {
      "value" = "Disabled"
    }

    # Storage account policies
    "effect-404c3081-a854-4457-ae30-26a93ef643f9" = {
      "value" = "Disabled"
    }

    "effect-4733ea7b-a883-42fe-8cac-97454c2a9e4a" = {
      "value" = "Disabled"
    }

    "effect-4fa4b6c0-31ca-4c0d-b10d-24b96f62a751" = {
      "value" = "Disabled"
    }

    "effect-34c877ad-507e-4c82-993e-3452a6e0ad3c" = {
      "value" = "Disabled"
    }

    "effect-2a1a9cdf-e04d-429a-8416-3bfb72a1b26f" = {
      "value" = "Disabled"
    }

    "effect-c9d007d0-c057-4772-b18c-01e546713bcd" = {
      "value" = "Disabled"
    }

    "effect-6edd7eda-6dd8-40f7-810d-67160c639cd9" = {
      "value" = "Disabled"
    }

    # Storage TLS version
    "effect-fe83a0eb-a853-422d-aac2-1bffd182c5d0" = {
      "value" = "Disabled"
    }

    # SQL auditing
    "effect-a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9" = {
      "value" = "Disabled"
    }

    # SQL TDE
    "effect-17k78e20-9358-41c9-923c-fb736d382a12" = {
      "value" = "Disabled"
    }

    # SQL retention
    "effect-89099bee-89e0-4b26-a5f4-165451757743" = {
      "value" = "Disabled"
    }

    # PostgreSQL policies
    "effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e43d" = {
      "value" = "Disabled"
    }

    "effect-5345bb39-67dc-4960-a1bf-427e16b9a0bd" = {
      "value" = "Disabled"
    }

    "effect-b52376f7-9612-48a1-81cd-1ffe4b61032c" = {
      "value" = "Disabled"
    }

    "effect-5e1de0e3-42cb-4ebc-a86d-61d0c619ca48" = {
      "value" = "Disabled"
    }

    "effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e442" = {
      "value" = "Disabled"
    }

    "effect-eb6f77b9-bd53-4e35-a23d-7f65d5f0e446" = {
      "value" = "Disabled"
    }

    "effect-24fba194-95d6-48c0-aea7-f65bf859c598" = {
      "value" = "Disabled"
    }

    # CosmosDB
    "effect-58440f8a-10c5-4151-bdce-dfbaad4a20b7" = {
      "value" = "Disabled"
    }

    # Storage encryption
    "effect-6fac406b-40ca-413b-bf8e-0bf964659c25" = {
      "value" = "Disabled"
    }

    # Key Vault logging
    "effect-cf820ca0-f99e-4f3e-84fb-66e913812d21" = {
      "value" = "Disabled"
    }

    # Activity log alerts
    "effect-c5447c04-a4d7-4ba8-a263-c9ee321a6858" = {
      "value" = "Disabled"
    }

    # Network Watcher
    "effect-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6" = {
      "value" = "Disabled"
    }

    # Disk encryption
    "effect-702dd420-7fcc-42c5-afe8-4026edd20fe0" = {
      "value" = "Disabled"
    }

    # Managed disks
    "effect-8405fdab-1faf-48aa-b702-999c9c172094" = {
      "value" = "Disabled"
    }

    # VM security
    "effect-1c30f9cd-b84c-49cc-aa2c-9288447cc3b3" = {
      "value" = "Disabled"
    }

    "effect-97566dd7-78ae-4997-8b36-1c7bfe0d8121" = {
      "value" = "Disabled"
    }

    # App Service policies
    "effect-a4af4a39-4135-47fb-b175-47fbdf85311d" = {
      "value" = "Disabled"
    }

    "effect-6d555dd1-86f2-4f1c-8ed7-5abae7c6cbab" = {
      "value" = "Disabled"
    }

    "effect-95bccee9-a7f8-4bec-9ee9-62c3473701fc" = {
      "value" = "Disabled"
    }

    "effect-399b2637-a50f-4f95-96f8-3a145476eb15" = {
      "value" = "Disabled"
    }

    "effect-4d24b6d4-5e53-4a4f-a7f4-618fa573ee4b" = {
      "value" = "Disabled"
    }

    "effect-f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b" = {
      "value" = "Disabled"
    }

    "effect-f9d614c5-c173-4d56-95a7-b4437057d193" = {
      "value" = "Disabled"
    }

    "effect-e2c1c086-2d84-4019-bff3-c44ccd95113c" = {
      "value" = "Disabled"
    }

    "effect-8c122334-9d20-4eb8-89ea-ac9a705b74ae" = {
      "value" = "Disabled"
    }

    "effect-cb510bfd-1cba-4d9f-a230-cb0976f4bb71" = {
      "value" = "Disabled"
    }

    "effect-0e60b895-3786-45da-8377-9c6b4b6ac5f9" = {
      "value" = "Disabled"
    }

    # Additional parameter values for specific policies that require them
    # TLS version for storage accounts
    "minimumTlsVersion-fe83a0eb-a853-422d-aac2-1bffd182c5d0" = {
      "value" = "TLS1_2"
    }

    # Auditing setting for SQL servers
    "setting-a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9" = {
      "value" = "enabled"
    }

    # Required retention days for Key Vault logs
    "requiredRetentionDays-cf820ca0-f99e-4f3e-84fb-66e913812d21" = {
      "value" = "365"
    }

    # Operation name for activity log alerts
    "operationName-c5447c04-a4d7-4ba8-a263-c9ee321a6858" = {
      "value" = "Microsoft.Authorization/policyAssignments/write"
    }

    # Network Watcher resource group
    "resourceGroupName-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6" = {
      "value" = "NetworkWatcherRG"
    }

    # Locations for Network Watcher
    "listOfLocations-b6e2945c-0b7b-40f5-9233-7a5323b5cdc6" = {
      "value" = []
    }
  }

  # No identity needed since we're only auditing (not remediating)
  assign_identity  = false
  location         = var.policy_assignment_location
  enforcement_mode = var.policy_enforcement_mode
}

# Output the CIS policy set assignment details
output "cis_selective_audit_policy_assignment_id" {
  description = "The ID of the CIS Azure Foundations v3.0.0 selective audit policy set assignment"
  value       = module.cis_selective_audit_policy_set.id
}

output "cis_selective_audit_policy_principal_id" {
  description = "The Principal ID of the CIS selective audit policy set assignment identity (if enabled)"
  value       = module.cis_selective_audit_policy_set.principal_id
}