locals {
  default_resource_group_name = "${var.product}-${var.env}"
  resource_group_name         = "${var.resource_group_name != "" ? var.resource_group_name : local.default_resource_group_name}"

  production_slot_app_settings = {
    SLOT                         = "PRODUCTION"
    WEBSITE_LOCAL_CACHE_OPTION   = "${var.website_local_cache_sizeinmb == "0" ? "Never" : "Always"}"
    WEBSITE_LOCAL_CACHE_SIZEINMB = "${var.website_local_cache_sizeinmb}"
  }
  asp_name = "${var.asp_name != "null" ? var.asp_name : local.default_resource_group_name}"
  asp_rg = "${var.asp_rg != "null" ? var.asp_rg : local.default_resource_group_name}"
  sp_name = "${var.env != "preview" ? local.asp_name : local.default_resource_group_name}"
  sp_rg = "${var.env != "preview" ? local.asp_rg : local.default_resource_group_name}"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"

  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.json")}"
}

# Create Application Insights for the service only if an instrumentation key to a specific instance wasn't provided
resource "azurerm_application_insights" "appinsights" {
  count = "${var.appinsights_instrumentation_key == "" ? 1 : 0}"

  name                = "${var.product}-appinsights-${var.env}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "${var.application_type}"
}

locals {
  # https://www.terraform.io/upgrade-guides/0-11.html#referencing-attributes-from-resources-with-count-0
  service_app_insights_instrumentation_key   = "${element(concat(azurerm_application_insights.appinsights.*.instrumentation_key, list("")), 0)}"
  effective_app_insights_instrumentation_key = "${var.appinsights_instrumentation_key == "" ? local.service_app_insights_instrumentation_key : var.appinsights_instrumentation_key}"

  app_settings_evaluated = {
    APPLICATION_INSIGHTS_IKEY = "${local.effective_app_insights_instrumentation_key}"

    # Support for nodejs apps (java apps to migrate to this env var in future PR)
    APPINSIGHTS_INSTRUMENTATIONKEY = "${local.effective_app_insights_instrumentation_key}"
  }
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.product}-${var.env}-webapp"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                 = "${var.product}-${var.env}"
    location             = "${var.location}"
    env                  = "${var.env}"
    app_settings         = "${jsonencode(merge(local.production_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    staging_app_settings = "${jsonencode(merge(var.staging_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    additional_host_name = "${var.additional_host_name}"
    stagingSlotName      = "${var.staging_slot_name}"
    is_frontend          = "${var.is_frontend}"
    security_enabled     = "${var.security_enabled}"
    https_only           = "${var.https_only}"
    capacity             = "${var.capacity}"
    instance_size        = "${var.instance_size}"
    web_sockets_enabled  = "${var.web_sockets_enabled}"
    asp_name             = "${local.sp_name}"
    asp_rg               = "${local.sp_rg}"
  }
}

resource "random_integer" "makeDNSupdateRunEachTime" {
  min     = 1
  max     = 99999
}

resource "null_resource" "consul" {
  triggers {
    trigger = "${azurerm_template_deployment.app_service_site.name}",
    forceRun = "${random_integer.makeDNSupdateRunEachTime.result}"
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
