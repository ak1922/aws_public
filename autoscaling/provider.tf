terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}
