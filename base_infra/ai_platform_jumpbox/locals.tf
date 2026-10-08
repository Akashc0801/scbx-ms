locals {
  c = var.common

  vm_name = join("-", concat(
    [local.c.org, "vm", local.c.app_code, var.jumpbox.base_name, local.c.env],
    local.c.region_code != null ? [local.c.region_code] : [],
    [var.jumpbox.iterator]
  ))
}
