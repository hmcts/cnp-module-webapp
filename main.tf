locals {
  default_resource_group_name = "${var.product}-${var.env}"
  resource_group_name = "${var.resource_group_name != "" ? var.resource_group_name : local.default_resource_group_name}"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.json")}"
}

# Create Application Insights for the service
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-appinsights-${var.env}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "${var.application_type}"
}

locals {
  app_settings_evaluated = {
    APPLICATION_INSIGHTS_IKEY = "${azurerm_application_insights.appinsights.instrumentation_key}"
    # Support for nodejs apps (java apps to migrate to this env var in future PR)
    APPINSIGHTS_INSTRUMENTATIONKEY = "${azurerm_application_insights.appinsights.instrumentation_key}"
  }
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
    app_settings = "${jsonencode(merge(var.app_settings_defaults, var.app_settings, local.app_settings_evaluated))}"
    hostname = "${var.product}-${var.env}.service.core-compute-${var.env}.internal"
    stagingSlotName = "${var.staging_slot_name}"
    capacity = "{var.instance_count}"
  }
}

resource "null_resource" "consul" {
  triggers {
    trigger = "${azurerm_template_deployment.app_service_site.name}"
  }

  # register 'production' slot dns
  provisioner "local-exec" {
    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}' '${var.subscription}'"
  }

  # register 'staging' slot dns
  provisioner "local-exec" {
    command = "bash -e ${path.module}/createDns.sh '${var.product}-${var.env}-${var.staging_slot_name}' 'core-infra-${var.env}' '${path.module}' '${var.ilbIp}' '${var.subscription}'"
  }
}
