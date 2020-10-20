resource "random_id" "server" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg" {
  name     = "aztferg-${random_id.server.hex}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "nw" {
  name                = "network-${random_id.server.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "sbnt" {
  name                 = "subnet-${random_id.server.hex}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.nw.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "pip" {
  count               = 3
  name                = "publicIp-${format("%00.0f", count.index)}-${random_id.server.hex}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "nic-${format("%00.0f", count.index)}-${random_id.server.hex}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "testconfiguration-${format("%00.0f", count.index)}"
    subnet_id                     = "${azurerm_subnet.sbnt.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip[count.index].id}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm1-${random_id.server.hex}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = [azurerm_network_interface.nic[0].id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_linux_virtual_machine" "vml" {
  name                  = "vm2-${random_id.server.hex}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = [azurerm_network_interface.nic[1].id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_windows_virtual_machine" "vmw" {
  name                  = "vm3-${random_id.server.hex}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = [azurerm_network_interface.nic[2].id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk3"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "tf"
    admin_username = "vmadmin"
    admin_password = "admin01!"
  }

  os_profile_windows_config {}
}
