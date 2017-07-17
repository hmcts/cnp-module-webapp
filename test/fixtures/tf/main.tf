provider "azurerm" {}

variable "product" {
  default = "probate"
}

variable "env" {
  default = "test"
}

resource "azurerm_resource_group" "management" {
  name     = "${var.product}-${var.env}"
  location = "UK South"
}
