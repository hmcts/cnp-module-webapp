data "template_file" "tmtemplate" {
  template = "${file("${path.module}/templates/trafficmanager.json")}"
}

resource "azurerm_template_deployment" "tmprofile" {
  template_body       = "${data.template_file.tmtemplate.rendered}"
  name                = "${var.product}-${var.env}-tm"
  resource_group_name = "${local.resource_group_name}"
  deployment_mode     = "Incremental"
  count               = "${var.shared_infra ? 0 : 1}"

  parameters = {
    name                 = "${var.product}-${var.env}"
    additional_host_name = "${var.additional_host_name}"
    is_frontend          = "${var.is_frontend}"
  }
}
