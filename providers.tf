terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "epicbooktfstate99"
    container_name       = "tfstate"
    key                  = "epicbook.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}