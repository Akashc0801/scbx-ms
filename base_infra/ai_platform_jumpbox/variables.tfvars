# Jump box for reaching the private Foundry landing zone from inside its VNet.
# Separate from the Foundry stack; destroy it when no longer needed.
# Names (workload format, as the network and Foundry stacks):
#   Resource group  az-rg-dtx-aiplatform-jumpbox-dev-001
#   Bastion         az-bas-dtx-aiplatform-jumpbox-dev-001  (Developer SKU)
#   VM              az-vm-dtx-aiplatform-jumpbox-dev-001   (computer name aifjumpbox01)

common = {
  # Naming module variables
  org                  = "az"
  env                  = "dev"
  app_code             = "dtx-aiplatform"
  naming_format        = "workload"
  location_region_code = "sea" # location only; no region in names
  au                   = "12345"
  bu                   = ""
  owner                = ""

  # Mandatory Tags
  environment         = "DEV"
  business_owner      = ""
  business_unit       = ""
  criticality         = ""
  cost_center         = ""
  data_classification = ""
  compliance          = ""
  app_name            = "AI Platform Jump Box"
  app_support         = "abc@xyz.com"
  budget_id           = ""
  status              = "Live"
  service             = "jumpbox"

  # Optional Tags
  region              = "southeastasia"
  description         = "Jump box for testing the private Foundry landing zone (dev)"
  notification_emails = []
  additional_tags     = {}
}

# Created by base_infra/ai_platform_network.
network = {
  virtual_network_name                = "az-vnet-dtx-aiplatform-foundry-dev-001"
  virtual_network_resource_group_name = "az-rg-dtx-aiplatform-foundry-dev-001"
  build_subnet_name                   = "az-snet-dtx-aiplatform-build-dev-001"
}

jumpbox = {
  # D/B/E-series sizes are NotAvailableForSubscription in Southeast Asia for
  # scbx-testing (2026-10-08); DC2ds_v3 (2 vCPU, 16 GB) is offered in zone 2 only.
  sku_size          = "Standard_DC2ds_v3"
  zone              = "2"
  admin_username    = "aifadmin"
  shutdown_time     = "2000"
  shutdown_timezone = "SE Asia Standard Time"
}
