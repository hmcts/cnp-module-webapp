# locals {
#   host                 = "${var.product}-${var.env}.service.core-compute-${var.env}.internal"
#   additional_host_name = "${var.additional_host_name = !"" ? var.additional_host_name : local.host }"
# }

data "template_file" "tmtemplate" {
  template = "${file("${path.module}/templates/trafficmanager.json")}"
}

resource "azurerm_template_deployment" "tmprofile" {
  template_body       = "${data.template_file.tmtemplate.rendered}"
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                 = "${var.product}-${var.env}"
    additional_host_name = "${var.additional_host_name}"
    is_frontend          = "${var.is_frontend}"
    gatewayId            = "${azurerm_application_gateway.waf.*.id}"
  }
}

# // Add multi backend logic for mult az here later
# resource "azurerm_traffic_manager_endpoint" "backend" {
#   count               = "${var.is_frontend}"
#   name                = "${var.product}-${var.env}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   profile_name        = "${var.product}-${var.env}"
#   target              = "${azurerm_public_ip.appGwPIP.fqdn}"
#   type                = "externalEndpoints"
#   weight              = 1
# }

