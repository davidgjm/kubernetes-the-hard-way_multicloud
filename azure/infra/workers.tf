#resource "azurerm_network_interface" "workers" {
#  count               = 3
#  name                = format("worker-%d", count.index)
#  location            = azurerm_resource_group.kthw.location
#  resource_group_name = azurerm_resource_group.kthw.name
#
#
#  ip_configuration {
#    name                          = format("worker-%d", count.index)
#    subnet_id                     = azurerm_subnet.kubernetes.id
#    private_ip_address_allocation = "Static"
#    private_ip_address            = cidrhost(var.kubernetes.cidr, 20 + count.index)
#  }
#}
#
#
#resource "azurerm_linux_virtual_machine" "workers" {
#  resource_group_name = azurerm_resource_group.kthw.name
#  location            = var.region
#  size                = var.vm_size
#
#  for_each = {
#    for nic in azurerm_network_interface.workers : nic.name => nic
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
#  custom_data = base64encode(file("cloud-init/worker-linux-amd64.yaml"))
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
#    type  = "worker"
#  }
#}
#
