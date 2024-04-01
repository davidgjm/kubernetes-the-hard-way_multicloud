#
#resource "azurerm_network_interface" "load_balancer" {
#  name                = var.dmz_zone.load_balancer.name
#  location            = azurerm_resource_group.kthw.location
#  resource_group_name = azurerm_resource_group.kthw.name
#
#
#  ip_configuration {
#    name                          = var.dmz_zone.load_balancer.name
#    subnet_id                     = azurerm_subnet.dmz.id
#    private_ip_address_allocation = "Static"
#    private_ip_address            = var.dmz_zone.load_balancer.private_ip
#    public_ip_address_id          = azurerm_public_ip.load_balancer.id
#  }
#}
#
#
#resource "azurerm_public_ip" "load_balancer" {
#  name                = var.dmz_zone.load_balancer.public_ip.name
#  allocation_method   = "Static"
#  location            = azurerm_resource_group.kthw.location
#  resource_group_name = azurerm_resource_group.kthw.name
#}
#
#
#resource "azurerm_linux_virtual_machine" "load_balancer" {
#  name                  = format("%s-vm", var.dmz_zone.load_balancer.name)
#  resource_group_name   = azurerm_resource_group.kthw.name
#  location              = var.region
#  size                  = var.vm_size
#  network_interface_ids = [azurerm_network_interface.load_balancer.id]
#
#  admin_username = var.vm_instance.ssh_key.username
#  admin_ssh_key {
#    public_key = file("~/.ssh/id_rsa.pub")
#    username   = var.vm_instance.ssh_key.username
#  }
#
#  custom_data = base64encode(file("cloud-init/load-balancer-linux-amd64.yaml"))
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
#    name                 = format("%s-vm-disk", var.dmz_zone.load_balancer.name)
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS"
#  }
#
#}
