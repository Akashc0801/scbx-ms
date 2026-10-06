locals {
  # Mandatory tags for Private DNS Zone resources
  mandatory_tags = {
    AppName        = var.app_name
    AppSupport     = var.app_support
    BusinessUnit   = var.business_unit
    ProductName    = var.product_name
    ProductVersion = var.product_version
    BudgetID       = var.budget_id
    Criticality    = var.criticality
    Environment    = var.environment
    Owner          = var.owner
    Status         = var.status
    BusinessOwner  = var.business_owner
  }

  # Combine mandatory tags with optional tags
  combined_tags = merge(local.mandatory_tags, var.tags != null ? var.tags : {})
}
