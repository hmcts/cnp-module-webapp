terraform {
  backend "azure" {}
}

data "terraform_remote_state" "moj_core_infrastructure" {
  backend = "azure"

  config {
    resource_group_name  = "contino-moj-tf-state"
    storage_account_name = "continomojtfstate"
    container_name       = "contino-moj-tfstate-container"
    key                  = "core-applications-infra/example/terraform.tfstate"
  }
}
