terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "giangleiacstate"
    storage_account_name = "giangletfstate01"
    container_name       = "iacstate"
    key                  = "platform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
