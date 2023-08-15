resource "azurerm_resource_group" "kthw" {
  name     = var.resource_group_name
  location = var.region
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

