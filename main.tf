# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/appservice.json")}"
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.product}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                 = "${var.product}"
    location             = "${var.location}"
    env                  = "${var.env}"
    app_settings         = "${jsonencode(merge(var.production_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    staging_app_settings = "${jsonencode(merge(var.staging_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    additional_host_name = "${var.additional_host_name}"
    stagingSlotName      = "${var.staging_slot_name}"
    https_only           = "${var.https_only}"
    web_sockets_enabled  = "${var.web_sockets_enabled}"
    asp_id               = "${var.asp_id}"
  }
}

#resource "null_resource" "consul" {
#  triggers {
#    trigger = "${azurerm_template_deployment.app_service_site.name}"
#  }


#  # register 'production' slot dns
#  provisioner "local-exec" {
#    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}' '${var.subscription}'"
#  }


# register 'staging' slot dns
#  provisioner "local-exec" {
#    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}-${var.staging_slot_name}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}' '${var.subscription}'"
#  }
#}

