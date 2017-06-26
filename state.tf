terraform {
  backend "azure" {}
}

data "terraform_remote_state" "moj_core_infrastructure" {
  backend = "azure"
  config {
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "core-applications-infra/example/terraform.tfstate"
  }
}