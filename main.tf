provider "azurerm" {
  subscription_id = "${var.azure_subscription}"
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "rg" {
    name     = "${var.name}"
    location = "${var.location}"
}