terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.40.0, < 4.0"
    }
  }

  required_version = ">= 1.3.0"
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  tenant_id = var.tenant_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
