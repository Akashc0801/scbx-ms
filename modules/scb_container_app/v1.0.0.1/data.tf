data "azurerm_container_app_environment" "ace_existing" {
  count               = var.create_container_app_environment ? 0 : 1
  name                = var.container_app_environment_name
  resource_group_name = var.existing_container_app_environment_resourcegroup_name
}