resource "azurerm_resource_group" "kthw" {
  name     = var.resource_group_name
  location = var.region
}



resource "azurerm_virtual_network" "kthw" {
  name                = "kubernetes-the-hard-way"
  location            = azurerm_resource_group.kthw.location
  resource_group_name = azurerm_resource_group.kthw.name
  address_space       = [var.vnet_cidr]

}