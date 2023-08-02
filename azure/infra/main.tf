terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }

  required_version = ">= 1.3.0"
}



# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  tenant_id = "38c6ec71-fc48-4e8a-9d77-4286c0874332"
}
