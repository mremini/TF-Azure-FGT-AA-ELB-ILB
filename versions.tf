terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    fortios = {
      source = "terraform-providers/fortios"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
