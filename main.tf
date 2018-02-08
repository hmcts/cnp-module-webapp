# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = "${var.location}"
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.v2.json")}"
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body = "${data.template_file.sitetemplate.rendered}"
  name = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode = "Incremental"

  parameters = {
    name = "${var.product}-${var.env}"
    location = "${var.location}"
    env = "${var.env}"
    app_settings = "${jsonencode(merge(var.app_settings_defaults, var.app_settings))}"
    hostname = "${var.product}-${var.env}.service.core-compute-${var.env}.internal"
    stagingSlotName = "${var.staging_slot_name}"
  }
}

resource "null_resource" "consul" {
  triggers {
    trigger = "${azurerm_template_deployment.app_service_site.name}"
  }

  # register 'production' slot dns
  provisioner "local-exec" {
    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}'"
  }

  # register 'staging' slot dns
  provisioner "local-exec" {
    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}-${var.staging_slot_name}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}'"
  }
}
