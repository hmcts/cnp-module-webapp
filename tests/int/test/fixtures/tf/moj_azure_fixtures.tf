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
  default = "int"
}

variable "app_settings" {
  type = "map"

  default = {
    TEST_SETTING1 = "Setting1"
    TEST_SETTING2 = "Setting2"
  }
}

data "terraform_remote_state" "sandbox_core_infra" {
  backend = "azure"

  config {
    resource_group_name  = "contino-moj-tf-state"
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "sandbox-core-infra/dev/terraform.tfstate"
  }
}

module "frontend" {
  source       = "../../../../../"
  product      = "${var.random_name}-frontend"
  location     = "${var.location}"
  env          = "${var.env}"
  asename      = "${data.terraform_remote_state.sandbox_core_infra.ase_name[0]}"
  app_settings = "${var.app_settings}"
}

output "random_name" {
  value = "${var.random_name}"
}
