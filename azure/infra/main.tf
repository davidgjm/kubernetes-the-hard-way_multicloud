resource "azurerm_resource_group" "kthw" {
  name     = var.resource_group_name
  location = var.region
}


data "azurerm_private_dns_zone" "dev" {
  name = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "cloud_native" {
  name                  = "cloud_native"
  private_dns_zone_name = data.azurerm_private_dns_zone.dev.name
  resource_group_name   = data.azurerm_private_dns_zone.dev.resource_group_name
  virtual_network_id    = azurerm_virtual_network.kthw.id
  registration_enabled = true
}

resource "azurerm_network_security_group" "internal" {
  location            = azurerm_resource_group.kthw.location
  name                = "internal"
  resource_group_name = azurerm_resource_group.kthw.name
}

resource "azurerm_network_security_rule" "internal_all" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.internal.name
  name                        = "everything"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  access                      = "Allow"
  priority                    = 100
  direction                   = "Inbound"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_virtual_network" "kthw" {
  name                = "kubernetes-the-hard-way"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
  address_space       = [var.vnet_cidr]

}

# This subnet holds both control plane nodes and worker nodes
resource "azurerm_subnet" "k8s" {
  name                 = var.kubernetes.name
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.kthw.name
  address_prefixes     = [var.kubernetes.cidr]
}

resource "azurerm_subnet" "control_plane" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.kthw.name
  address_prefixes     = [var.control_plane_cidr]
}


resource "azurerm_subnet" "workers" {
  name                 = var.workers.name
  address_prefixes     = [var.workers.cidr]
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.kthw.name
}

