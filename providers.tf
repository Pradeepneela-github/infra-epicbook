terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  # Remote backend stores your state file in Azure Blob Storage
  # This is required for Azure DevOps pipelines to share state
  backend "azurerm" {
    resource_group_name  = "epicbook-tfstate-rg"
    storage_account_name = "epicbooktfstate99"
    container_name       = "tfstate"
    key                  = "epicbook.tfstate"
  }
}

provider "azurerm" {
  features {}
}