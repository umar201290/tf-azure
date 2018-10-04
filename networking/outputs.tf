output "RG-name" {
  value = "${azurerm_resource_group.myterraformgroup.name}"
}

output "vnet-id" {
  value = "${azurerm_virtual_network.myterraformnetwork.id}"
}

output "subnet-id" {
  value = "${azurerm_subnet.myterraformsubnet.id}"
}
