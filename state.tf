terraform {
  backend "azure" {
    key = "${var.name}/${var.env}/terrarform.tfstate"
  }
}