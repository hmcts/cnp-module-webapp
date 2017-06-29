provider "azurerm" {}

resource "azurerm_resource_group" "management" {
  name     = "test-probate"
  location = "UK South"
}
