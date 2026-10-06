resource "azurerm_disk_access" "this" {
  count = local.create_disk_access ? 1 : 0

  name                = var.disk_access.name
  resource_group_name = coalesce(var.disk_access.resource_group_name, var.resource_group_name)
  location            = coalesce(var.disk_access.location, local.vm_location)
  tags                = var.disk_access.tags
}

resource "azurerm_private_endpoint" "disk_access" {
  count = local.create_disk_access_private_endpoint ? 1 : 0

  name                          = coalesce(var.disk_access.private_endpoint.name, "pep-${local.vm_name}-diskaccess")
  resource_group_name           = coalesce(var.disk_access.private_endpoint.resource_group_name, var.disk_access.resource_group_name, var.resource_group_name)
  location                      = coalesce(var.disk_access.location, local.vm_location)
  subnet_id                     = var.disk_access.private_endpoint.subnet_resource_id
  custom_network_interface_name = var.disk_access.private_endpoint.network_interface_name
  tags                          = local.tags

  private_service_connection {
    name                           = coalesce(var.disk_access.private_endpoint.private_service_connection_name, "psc-${local.vm_name}-diskaccess")
    is_manual_connection           = false
    private_connection_resource_id = local.disk_access_resource_id
    subresource_names              = ["disks"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.disk_access.private_endpoint.private_dns_zone_resource_ids) > 0 ? [1] : []

    content {
      name                 = var.disk_access.private_endpoint.private_dns_zone_group_name
      private_dns_zone_ids = var.disk_access.private_endpoint.private_dns_zone_resource_ids
    }
  }
}

resource "azapi_update_resource" "os_disk_access" {
  count = local.os_disk_access_patch_enabled ? 1 : 0

  type        = "Microsoft.Compute/disks@2023-04-02"
  resource_id = local.os_disk_resource_id

  body = {
    properties = merge(
      local.os_disk_effective_disk_access_resource_id != null ? {
        diskAccessId = local.os_disk_effective_disk_access_resource_id
      } : {},
      local.os_disk_effective_network_access_policy != null ? {
        networkAccessPolicy = local.os_disk_effective_network_access_policy
      } : {},
      try(var.os_disk.public_network_access_enabled, null) != null ? {
        publicNetworkAccess = var.os_disk.public_network_access_enabled ? "Enabled" : "Disabled"
      } : {}
    )
  }

  depends_on = [
    azurerm_linux_virtual_machine.this,
    azurerm_windows_virtual_machine.this,
    azurerm_disk_access.this
  ]
}
