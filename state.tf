terraform {
  backend "azure" {
    key = "appservice.environment.terrarform.tfstate"
  }
}