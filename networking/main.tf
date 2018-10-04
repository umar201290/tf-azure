# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "${var.RG}"
  location = "${var.loc}"
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "${var.vnet-name}"
  address_space       = ["${var.vnet-cidr}"]
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "${var.subnet-name}"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
  address_prefix       = "${var.subnet-cidr}"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                         = "${var.public-ip}"
  location                     = "${var.loc}"
  resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
  public_ip_address_allocation = "dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

resource "azurerm_network_security_rule" "security_rule_ssh" {
  name                        = "ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.myterraformnsg.name}"
}

resource "azurerm_network_security_rule" "security_rule_http" {
  name                        = "http"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.myterraformnsg.name}"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                      = "myNIC"
  location                  = "${var.loc}"
  resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "${var.vm-name}"
  location              = "${var.loc}"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.vm-name}"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    #ssh_keys {
    #path     = "/home/azureuser/.ssh/authorized_keys"
    #key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
    #}
  }

  #boot_diagnostics {
  #   enabled = "false"
  #storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  #} 
}
