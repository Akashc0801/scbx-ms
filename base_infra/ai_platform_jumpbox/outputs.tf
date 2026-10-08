output "resource_group_name" {
  description = "Jump box resource group."
  value       = module.resource_group.name
}

output "bastion_name" {
  description = "Bastion Developer host."
  value       = module.bastion.name
}

output "jumpbox" {
  description = "Jump box VM name, private IP and admin user."
  value = {
    name           = module.jumpbox.name
    private_ip     = module.jumpbox.network_interfaces["nic"].private_ip_address
    admin_username = module.jumpbox.admin_username
  }
}

output "jumpbox_admin_password" {
  description = "Generated local admin password. Read with: terraform output -raw jumpbox_admin_password"
  value       = module.jumpbox.admin_password
  sensitive   = true
}
