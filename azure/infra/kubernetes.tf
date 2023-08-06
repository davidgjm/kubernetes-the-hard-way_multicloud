
resource "azurerm_network_interface" "kubernetes_controllers" {
  count = 3
  name                = format("controller-%d", count.index)
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name


  ip_configuration {
    name                          = format("controller-%d", count.index)
    subnet_id                     = azurerm_subnet.k8s.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.k8s_subnet_cidr, 10 + count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "kubernetes_controllers" {
  network_security_group_id = azurerm_network_security_group.internal.id
  for_each                  = {
    for nic in azurerm_network_interface.kubernetes_controllers : nic.name => nic
  }
  network_interface_id      = each.value.id
}

resource "azurerm_private_dns_a_record" "kubernetes_controllers" {
  zone_name           = azurerm_private_dns_zone.dev.name
  resource_group_name = azurerm_resource_group.kthw.name
  ttl                 = 30 * 60

  for_each                  = {
    for nic in azurerm_network_interface.kubernetes_controllers : nic.name => nic
  }
  name                = each.key
  records             = [each.value.ip_configuration[0].private_ip_address]
}


resource "azurerm_linux_virtual_machine" "controllers" {
  resource_group_name   = azurerm_resource_group.kthw.name
  location              = var.region
  size                  = var.vm_size

  for_each                  = {
    for nic in azurerm_network_interface.kubernetes_controllers : nic.name => nic
  }


  name                  = each.key
  network_interface_ids = [each.value.id]

  admin_username = var.admin_username
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")
    username   = var.admin_username
  }

  custom_data = base64encode(file("cloud-init/controller.yaml"))

  eviction_policy = "Delete"
  priority        = "Spot"
  max_bid_price   = var.spot_max_price

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = format("osdisk-%s",each.key)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    group = "kubernetes-the-hard-way"
    type = "controller"
  }
}