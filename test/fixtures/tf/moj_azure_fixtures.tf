provider "azurerm" {}

variable "location" {
  default = "UK South"
}

variable "product" {
  default = "inspect"
}

variable "env" {
  default = "int"
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
  source   = "git::https://7fed81743d89f663cc1e746f147c83a74e7b1318@github.com/contino/moj-module-webapp?ref=0.0.16"
  product  = "${var.product}-frontend"
  location = "${var.location}"
  env      = "${var.env}"
  asename  = "${data.terraform_remote_state.core_sandbox_infrastructure.ase_name[0]}"
}
