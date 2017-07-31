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
  default = "${jsonencode(map("TEST_SETTING", "Setting"))}"
}

data "terraform_remote_state" "core_sandbox_infrastructure" {
  backend = "azure"

  config {
    resource_group_name  = "contino-moj-tf-state"
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "sandbox-core-infra/sandbox/terraform.tfstate"
  }
}

module "frontend" {
  source       = "git::https://7fed81743d89f663cc1e746f147c83a74e7b1318@github.com/contino/moj-module-webapp?ref=0.0.25"
  product      = "${var.random_name}-frontend"
  location     = "${var.location}"
  env          = "${var.env}"
  asename      = "${data.terraform_remote_state.core_sandbox_infrastructure.ase_name[0]}"
  app_settings = "${var.app_settings}"
}

output "random_name" {
  value = "${var.random_name}"
}
