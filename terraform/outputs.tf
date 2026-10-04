output "resource_group_name" {
  description = "Resource group containing the lab"
  value       = azurerm_resource_group.lab.name
}

output "vm_name" {
  description = "Name of the Ubuntu VM"
  value       = azurerm_linux_virtual_machine.lab.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.lab.ip_address
}

output "ssh_command" {
  description = "Command to connect to the VM."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.lab.ip_address}"
}

output "ansible_inventory" {
  description = "Basic Ansible inventory entry for the VM."
  value       = "[web]\n${azurerm_linux_virtual_machine.lab.name} ansible_host=${azurerm_public_ip.lab.ip_address} ansible_user=${var.admin_username}"
}
