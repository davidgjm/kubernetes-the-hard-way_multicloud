
resource "azurerm_public_ip" "dmz" {
  name                = "dmz"
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
}


resource "azurerm_subnet" "dmz" {
  name                 = "dmz"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.dmz_subnet_cidr]
  resource_group_name  = azurerm_resource_group.kthw.name
}


resource "azurerm_network_security_group" "dmz" {
  location            = azurerm_resource_group.kthw.location
  name                = "dmz"
  resource_group_name = azurerm_resource_group.kthw.name
}

resource "azurerm_network_security_rule" "dmz_ssh" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.dmz.name
  name                        = "ssh"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  access                      = "Allow"
  priority                    = 100
  direction                   = "Inbound"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface" "dmz" {
  name                = "dmz-nic"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name


  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.dmz.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.dmz.id
  }
}

resource "azurerm_network_interface_security_group_association" "dmz" {
  network_interface_id      = azurerm_network_interface.dmz.id
  network_security_group_id = azurerm_network_security_group.dmz.id
}

resource "azurerm_linux_virtual_machine" "dmz" {
  name                  = "dmz"
  resource_group_name   = azurerm_resource_group.kthw.name
  location              = var.region
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.dmz.id]

  admin_username = var.admin_username
  admin_ssh_key {
    public_key                      = file("~/.ssh/id_rsa.pub")
    username                        = var.admin_username
  }

  custom_data = base64encode(file("cloud-init/dmz.yaml"))

  eviction_policy = "Delete"
  priority = "Spot"
  max_bid_price = var.spot_max_price

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}