provider "azurerm" {}

variable "location" {
  default = "UK South"
}

variable "product" {
  default = "inspect"
}

variable "random_name" {}

variable "env" {
  default = "int"
}

variable "app_settings" {
  type = "map"

  default = {
    TEST_SETTING1 = "Setting1"
    TEST_SETTING2 = "Setting2"
  }
}

data "terraform_remote_state" "core_sandbox_infrastructure" {
  backend = "azure"

  config {
    resource_group_name  = "contino-moj-tf-state"
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "sandbox-compute-sample/${var.env}/terraform.tfstate"
  }
}

module "frontend" {
  source       = "../../../../../"
  product      = "${var.random_name}-frontend"
  location     = "${var.location}"
  env          = "${var.env}"
  asename      = "${data.terraform_remote_state.core_sandbox_infrastructure.ase_name[3]}"
  app_settings = "${var.app_settings}"
}

output "random_name" {
  value = "${var.random_name}"
}
