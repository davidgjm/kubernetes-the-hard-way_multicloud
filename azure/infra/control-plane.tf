################################################################################
## API Server Load Balancer
################################################################################
resource "azurerm_public_ip" "api_server_pip" {
  name                = var.api_server_lb.public_ip.name
  allocation_method   = "Static"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
}

resource "azurerm_network_interface" "api_server_lb" {
  name                = var.api_server_lb.name
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name


  ip_configuration {
    name                          = var.api_server_lb.name
    subnet_id                     = azurerm_subnet.control_plane.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.api_server_lb.private_ip
    public_ip_address_id          = azurerm_public_ip.api_server_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "api_server_lb" {
  name                  = format("%s-vm", var.api_server_lb.name)
  resource_group_name   = azurerm_resource_group.kthw.name
  location              = var.region
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.api_server_lb.id]

  disable_password_authentication = true
  admin_username                  = var.vm_instance.ssh_key.username
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")
    username   = var.vm_instance.ssh_key.username
  }

  custom_data = base64encode(file("cloud-init/load-balancer-linux-amd64.yaml"))

  eviction_policy = "Delete"
  priority        = "Spot"
  max_bid_price   = var.spot_max_price

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  os_disk {
    name                 = format("%s-vm-disk", var.api_server_lb.name)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


################################################################################
## API Server Control Nodes
################################################################################

#resource "azurerm_network_interface" "kubernetes_controllers" {
#  count               = 3
#  name                = format("controller-%d", count.index)
#  location            = azurerm_resource_group.kthw.location
#  resource_group_name = azurerm_resource_group.kthw.name
#
#
#  ip_configuration {
#    name                          = format("controller-%d", count.index)
#    subnet_id                     = azurerm_subnet.kubernetes.id
#    private_ip_address_allocation = "Static"
#    private_ip_address            = cidrhost(var.kubernetes.cidr, 10 + count.index)
#  }
#}
#
#
#resource "azurerm_linux_virtual_machine" "controllers" {
#  resource_group_name = azurerm_resource_group.kthw.name
#  location            = var.region
#  size                = var.vm_size
#
#  for_each = {
#    for nic in azurerm_network_interface.kubernetes_controllers : nic.name => nic
#  }
#
#
#  name                  = each.key
#  network_interface_ids = [each.value.id]
#
#  admin_username = var.vm_instance.ssh_key.username
#  admin_ssh_key {
#    username   = var.vm_instance.ssh_key.username
#    public_key = file(var.vm_instance.ssh_key.vm_public_key)
#  }
#
#  custom_data = base64encode(file("cloud-init/controller-linux-amd64.yaml"))
#
#  eviction_policy = "Delete"
#  priority        = "Spot"
#  max_bid_price   = var.spot_max_price
#
#  source_image_reference {
#    publisher = var.vm_image.publisher
#    offer     = var.vm_image.offer
#    sku       = var.vm_image.sku
#    version   = var.vm_image.version
#  }
#
#  os_disk {
#    name                 = format("osdisk-%s", each.key)
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS"
#  }
#
#  tags = {
#    group = "kubernetes-the-hard-way"
#    type  = "controller"
#  }
#}
