terraform {
  required_version = ">=0.12"

  cloud {
    organization = "JrPatterson"

    workspaces {
      name = "Azure-CV-Workspace"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}