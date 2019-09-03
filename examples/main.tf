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

# Both default_asp_name_and_rg and params_asp_name_and_rg must be included to 
# ensure that the dependencies and references work correctly in both examples.
# A common error is to include a new dependsOn resourceId without the RG
# parameter, which will work for default_asp_name_and_rg but fail on
# params_asp_name_and_rg.
module "default_asp_name_and_rg" {
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
	
	# asp_name = "idam-web-frontend-example-sandbox"
  # asp_rg = "idam-web-frontend-example-sandbox"

	app_settings         = {
		WEBSITE_NODE_DEFAULT_VERSION = "8.8.0"
	}
}

module "params_asp_name_and_rg" {
	source               = "../"
	product              = "${var.product}-backend-example"
	location             = "${var.location}"
	appinsights_location = "${var.location}"
	env                  = "${var.env}"
	capacity             = "${var.capacity}"
	asp_name             = "${var.product}-${var.env}"
	subscription         = "${var.subscription}"
	common_tags          = "${var.common_tags}"
	
	asp_name = "idam-backend-example-sandbox"
  asp_rg = "idam-backend-example-sandbox"

	app_settings         = {
		WEBSITE_NODE_DEFAULT_VERSION = "8.8.0"
	}
}
