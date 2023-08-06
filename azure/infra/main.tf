resource "azurerm_resource_group" "kthw" {
  name     = var.resource_group_name
  location = var.region
}


resource "azurerm_private_dns_zone" "dev" {
  name                = var.private_domain
  resource_group_name = azurerm_resource_group.kthw.name

}

resource "azurerm_private_dns_zone_virtual_network_link" "cloud_native" {
  name                  = "cloud_native"
  private_dns_zone_name = azurerm_private_dns_zone.dev.name
  resource_group_name   = azurerm_resource_group.kthw.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
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


resource "azurerm_virtual_network" "vnet" {
  name                = "kubernetes-the-hard-way"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
  address_space       = [var.vnet_cidr]

}

# This subnet holds both control plane nodes and worker nodes
resource "azurerm_subnet" "k8s" {
  name                 = "kubernetes"
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.k8s_subnet_cidr]
}

resource "azurerm_subnet" "control_plane" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.control_plane_cidr]
}


resource "azurerm_subnet" "nodes_plane" {
  name                 = "nodes-plane"
  address_prefixes     = [var.nodes_cidr]
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}


resource "azurerm_subnet" "utility" {
  name                 = "utility"
  address_prefixes     = [var.utility_cidr]
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

