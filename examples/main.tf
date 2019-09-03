provider "azurerm" {
  version = "1.22.1"
  subscription_id = "${var.subscription_id}"
}
variable "subscription" {}

variable "subscription_id" {}

variable "product" {
  default = "idam"
}

variable "location" {
  default = "UK South"
}

variable "env" {
  default = "sandbox"
}

variable "capacity" {
  default = "1"
}


variable "common_tags" {
  default = {
    "Team Name" = "IDAM"
  }
}

module "frontend" {
	source               = "../"
	product              = "${var.product}-frontend-example"
	location             = "${var.location}"
	appinsights_location = "${var.location}"
	env                  = "${var.env}"
	capacity             = "${var.capacity}"
	is_frontend          = true
	asp_name             = "${var.product}-${var.env}"
	subscription         = "${var.subscription}"
	common_tags          = "${var.common_tags}"
	app_settings         = {
		WEBSITE_NODE_DEFAULT_VERSION = "8.8.0"
	}
}
