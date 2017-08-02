# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = "${var.location}"
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.json")}"
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name     = "${var.product}-${var.env}"
    aseName  = "${var.asename}"
    location = "${var.location}"
    env      = "${var.env}"

    #app_settings = "${jsonencode(var.app_settings)}"
  }
}

# TODO refactor outputs once module is extracted
output "gitendpoint" {
  value = "${var.product}-${var.env}.scm.${var.product}-${var.env}.p.azurewebsites.net/${var.product}-${var.env}.git"
}
