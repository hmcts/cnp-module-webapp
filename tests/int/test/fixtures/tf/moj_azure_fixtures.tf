provider "azurerm" {}

variable "location" {
  default = "UK South"
}

variable "product" {
  default = "inspect"
}

variable "random_name" {}
variable "branch_name" {}

variable "env" {
  default = "sandboxtestsupport"
}

variable "app_settings" {
  type = "map"

  default = {
    TEST_SETTING1 = "Setting1"
    TEST_SETTING2 = "Setting2"
  }
}

module "frontend" {
  source       = "../../../../../"
  product      = "${var.random_name}-frontend"
  location     = "${var.location}"
  env          = "${var.env}"
  app_settings = "${var.app_settings}"
}

output "random_name" {
  value = "${var.random_name}"
}

variable "appGateway" {
  default = "appgateway"
}

variable "key_vault_id" {
  default = "keyvaultid"
}

variable "key_vault_uri" {
  default = "keyvaulturi"
}
