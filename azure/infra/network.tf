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

resource "azurerm_virtual_network" "vnet" {
  name                = "kubernetes-the-hard-way"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
  address_space       = ["10.240.0.0/24"]

  subnet {
    name           = "dmz"
    address_prefix = "10.240.0.0/28"
    security_group = azurerm_network_security_group.dmz.id
  }

  subnet {
    name           = "control-plane"
    address_prefix = "10.240.0.16/28"
    security_group = azurerm_network_security_group.internal.id
  }

  subnet {
    name           = "nodes-plane"
    address_prefix = "10.240.0.32/28"
    security_group = azurerm_network_security_group.internal.id
  }

  subnet {
    name           = "load-balancing"
    address_prefix = "10.240.0.64/28"
    security_group = azurerm_network_security_group.internal.id
  }

}