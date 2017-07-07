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
  name                = "${var.env}-${var.product}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Complete"

  parameters = {
    name                  = "${var.product}-${var.env}"
    aseName               = "${var.asename}"
    qaSlotName            = "${var.product}-${var.env}-${var.qaslotname}"
    devSlotName           = "${var.product}-${var.env}-${var.devslotname}"
    lastKnownGoodSlotName = "${var.product}-${var.env}-${var.lastknowngoodslotname}"
    location              = "${var.location}"
    env                   = "${var.env}"
  }
}

# TODO refactor outputs once module is extracted
output "gitendpoint" {
  value = "${var.product}-${var.env}.scm.${var.product}-${var.env}.p.azurewebsites.net/${var.product}-${var.env}.git"
}
