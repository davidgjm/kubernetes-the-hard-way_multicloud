resource "azurerm_virtual_network" "kthw" {
  name                = "kubernetes-the-hard-way"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
  address_space       = [var.vnet_cidr]

}

################################################################################
## Subnet `DMZ`
################################################################################
#resource "azurerm_subnet" "dmz" {
#  name                 = "dmz-zone"
#  virtual_network_name = azurerm_virtual_network.kthw.name
#  address_prefixes     = [var.dmz_zone.cidr]
#  resource_group_name  = azurerm_resource_group.kthw.name
#}
#
#resource "azurerm_network_security_group" "dmz" {
#  location            = azurerm_resource_group.kthw.location
#  name                = "dmz"
#  resource_group_name = azurerm_resource_group.kthw.name
#}
#resource "azurerm_network_security_rule" "dmz_ssh" {
#  resource_group_name         = azurerm_resource_group.kthw.name
#  network_security_group_name = azurerm_network_security_group.dmz.name
#  name                        = "ssh"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_range      = "22"
#  access                      = "Allow"
#  priority                    = 100
#  direction                   = "Inbound"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#}
#resource "azurerm_subnet_network_security_group_association" "dmz" {
#  network_security_group_id = azurerm_network_security_group.dmz.id
#  subnet_id                 = azurerm_subnet.dmz.id
#}
#
#
#resource "azurerm_network_security_group" "load_balancer" {
#  name                = "k8s-api-server-nlb"
#  location            = azurerm_resource_group.kthw.location
#  resource_group_name = azurerm_resource_group.kthw.name
#}
#resource "azurerm_network_security_rule" "api_server" {
#  resource_group_name         = azurerm_resource_group.kthw.name
#  network_security_group_name = azurerm_network_security_group.load_balancer.name
#  name                        = "AllowApiServer"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_range      = "6443"
#  access                      = "Allow"
#  priority                    = 110
#  direction                   = "Inbound"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#}
#
#resource "azurerm_subnet_network_security_group_association" "load_balancer" {
#  network_security_group_id = azurerm_network_security_group.load_balancer.id
#  subnet_id                 = azurerm_subnet.dmz.id
#}

################################################################################
## Subnet `k8s-control-plane`
################################################################################
resource "azurerm_subnet" "control_plane" {
  name                 = var.control_plane.name
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.kthw.name
  address_prefixes     = [var.control_plane.subnet_cidr]
}

resource "azurerm_network_security_group" "nsg_control_plane" {
  location            = azurerm_resource_group.kthw.location
  name                = var.control_plane.name
  resource_group_name = azurerm_resource_group.kthw.name
}
resource "azurerm_network_security_rule" "allow_api_server_access" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nsg_control_plane.name
  name                        = "AllowApiServerInbound"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = var.control_plane.subnet_cidr
  destination_port_ranges      = ["443","6443"]
  access                      = "Allow"
  priority                    = 250
  direction                   = "Inbound"
}
resource "azurerm_network_security_rule" "allow_nodes" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nsg_control_plane.name
  name                        = "AllowNodeInbound"
  protocol                    = "*"
  source_address_prefix       = var.nodes.subnet_cidr
  source_port_range           = "*"
  destination_address_prefix  = var.control_plane.subnet_cidr
  destination_port_range      = "*"
  access                      = "Allow"
  priority                    = 251
  direction                   = "Inbound"
}
resource "azurerm_network_security_rule" "allow_ssh" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nsg_control_plane.name
  name                        = "AllowSshInbound"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = var.control_plane.subnet_cidr
  destination_port_range      = "22"
  access                      = "Allow"
  priority                    = 252
  direction                   = "Inbound"
}

resource "azurerm_subnet_network_security_group_association" "nsg_nodes" {
  network_security_group_id = azurerm_network_security_group.nsg_control_plane.id
  subnet_id            =  azurerm_subnet.control_plane.id
}


################################################################################
## Subnet `k8s-nodes`
################################################################################

resource "azurerm_subnet" "nodes" {
  name                 = var.nodes.name
  address_prefixes     = [var.nodes.subnet_cidr]
  resource_group_name  = azurerm_resource_group.kthw.name
  virtual_network_name = azurerm_virtual_network.kthw.name
}

resource "azurerm_network_security_group" "nodes" {
  location            = azurerm_resource_group.kthw.location
  name                = "k8s-nodes"
  resource_group_name = azurerm_resource_group.kthw.name
}
resource "azurerm_network_security_rule" "allow_control_plane" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nodes.name
  name                        = "AllowControlPlaneInbound"
  protocol                    = "*"
  source_address_prefix       = var.control_plane.subnet_cidr
  source_port_range           = "*"
  destination_address_prefix  = var.nodes.subnet_cidr
  destination_port_range      = "*"
  access                      = "Allow"
  priority                    = 250
  direction                   = "Inbound"
}
resource "azurerm_network_security_rule" "allow_subnet_internal" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nodes.name
  name                        = "AllowIntratoSubnetInbound"
  protocol                    = "*"
  source_address_prefix       = var.control_plane.subnet_cidr
  source_port_range           = "*"
  destination_address_prefix  = var.nodes.subnet_cidr
  destination_port_range      = "*"
  access                      = "Allow"
  priority                    = 251
  direction                   = "Inbound"
}
resource "azurerm_network_security_rule" "DenyVnetInBound" {
  resource_group_name         = azurerm_resource_group.kthw.name
  network_security_group_name = azurerm_network_security_group.nodes.name
  name                        = "DenyVnetInBound"
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  access                      = "Deny"
  priority                    = 4096
  direction                   = "Inbound"
}
resource "azurerm_subnet_network_security_group_association" "workers" {
  network_security_group_id = azurerm_network_security_group.nodes.id
  subnet_id            =  azurerm_subnet.nodes.id
}



################################################################################
## Subnet `kubernetes`
################################################################################
# This subnet holds both control plane nodes and worker nodes
#resource "azurerm_subnet" "kubernetes" {
#  name                 = var.kubernetes.name
#  resource_group_name  = azurerm_resource_group.kthw.name
#  virtual_network_name = azurerm_virtual_network.kthw.name
#  address_prefixes     = [var.kubernetes.cidr]
#}
#resource "azurerm_subnet_network_security_group_association" "shared_subnet_workers" {
#  network_security_group_id = azurerm_network_security_group.workers.id
#  subnet_id            =  azurerm_subnet.kubernetes.id
#}
#
#resource "azurerm_network_security_group" "internal" {
#  location            = azurerm_resource_group.kthw.location
#  name                = "internal"
#  resource_group_name = azurerm_resource_group.kthw.name
#}
#resource "azurerm_subnet_network_security_group_association" "kubernetes" {
#  network_security_group_id = azurerm_network_security_group.internal.id
#  subnet_id                 = azurerm_subnet.kubernetes.id
#}
