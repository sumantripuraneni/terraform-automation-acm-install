terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    kubectl = {
      source = "alon-dotan-starkware/kubectl"
      version = "1.11.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.43"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.75.0"
    }

    azureopenshift = {
      source  = "rh-mobb/azureopenshift"
      version = "0.2.0-pre"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}

