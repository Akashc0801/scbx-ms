module "standard_bastion_host" {
  #checkov:skip=CKV_TF_1:Module uses registry source pinned to a specific version
  source = "../../"

  # Bastion Host Configuration
  resource_group_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-security-prod-myw-01"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  # IP Configuration
  ip_configuration = {
    subnet_id                        = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network-prod-myw-01/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-myw-01/subnets/AzureBastionSubnet"
    create_public_ip                 = true
    public_ip_address_name           = "pip-bastion-prod-myw-01"
    public_ip_merge_with_module_tags = true
  }

  # Security Features
  copy_paste_enabled        = true
  file_copy_enabled         = true
  ip_connect_enabled        = true
  kerberos_enabled          = false
  session_recording_enabled = true
  shareable_link_enabled    = false
  tunneling_enabled         = true
  scale_units               = 4

  # Required Naming Variables (passed to naming module)
  env      = "p"     # Production environment
  au       = "12345" # Application unit
  owner    = "security-team@example.com"
  app_code = "bastion" # Application code for naming
  bu       = "IT"      # Business unit code

  # Required Business Tags
  business_owner = "Head of Security Operations"
  business_unit  = "GTD-ISD-SecOps"
  app_name       = "SCB-BastionHost"
  budget_id      = "83254"

  # Required Operation Tags
  criticality = "T1"      # Tier 1 - Mission Critical
  status      = "Active"  # Currently active
  service     = "Bastion" # Bastion service

  # Required Finance Tags
  cost_center = "383-80572"

  # Required Governance Tags
  environment         = "Production"
  data_classification = "InfrastructureOnly"
  compliance          = "ISO27001"

  # Optional Tags
  region              = "MYW" # Malaysia West region
  description         = "Standard bastion host for secure production access"
  notification_emails = ["mss_ceat@example.com", "security-team@example.com"]

  # Optional Workload Tags
  app_id             = "SCB-MYW-SEC01-00001"
  auto_delete        = "No"
  retention          = "90days"
  integration_id     = "Bastion-terraform-mod"
  experiment_phase   = "None"
  sandbox_type       = "Production"
  os                 = "Windows"
  patch_policy       = "Monthly-Standard"
  maintenance_window = "Sun-02:00Z"

  # Resource Management
  lock = {
    kind = "CanNotDelete"
    name = "bastion-lock"
  }

  # Monitoring
  diagnostic_settings = {
    default = {
      name                           = "diag-bastion-prod-myw-01"
      log_categories                 = ["BastionAuditLogs"]
      metric_categories              = ["AllMetrics"]
      workspace_resource_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring-prod-myw-01/providers/Microsoft.OperationalInsights/workspaces/log-monitoring-prod-myw-01"
      log_analytics_destination_type = "Dedicated"
    }
  }

  enable_telemetry = true
}
