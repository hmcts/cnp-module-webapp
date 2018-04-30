data "template_file" "tmtemplate" {
  template = "${file("${path.module}/templates/trafficmanager.json")}"
}

resource "azurerm_template_deployment" "tmprofile" {
  template_body       = "${data.template_file.tmtemplate.rendered}"
  name                = "${var.product}-${var.env}-tm"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                 = "${var.product}-${var.env}"
    additional_host_name = "${var.additional_host_name}"
    is_frontend          = "${var.is_frontend}"
    env                  = "${var.env}"
    team_name            = "${var.team_name}"
    team_contact         = "${var.team_contact}"
    destroy_me           = "${var.destroy_me}"
  }
}
