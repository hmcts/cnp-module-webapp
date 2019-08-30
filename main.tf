locals {
  default_resource_group_name = "${var.product}-${var.env}${var.deployment_target}"
  resource_group_name         = "${var.resource_group_name != "" ? var.resource_group_name : local.default_resource_group_name}"

  production_slot_app_settings = {
    SLOT                         = "PRODUCTION"
    WEBSITE_LOCAL_CACHE_OPTION   = "${var.website_local_cache_sizeinmb == "0" ? "Never" : "Always"}"
    WEBSITE_LOCAL_CACHE_SIZEINMB = "${var.website_local_cache_sizeinmb}"
  }

  asp_name = "${var.asp_name != "null" ? var.asp_name : local.default_resource_group_name}"
  asp_rg   = "${var.asp_rg != "null" ? var.asp_rg : local.default_resource_group_name}"
  sp_name  = "${var.env != "preview" ? local.asp_name : local.default_resource_group_name}"
  sp_rg    = "${var.env != "preview" ? local.asp_rg : local.default_resource_group_name}"

  preview = "${var.env != "preview" ? 0 : 1}"
  envcore = "${var.deployment_target != "" ? "env" : "core" }"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"

  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
  
  # On creation, resource group is not ready without delay.
  provisioner "local-exec" {
    command = "sleep 120"
    on_failure = "continue"
  }
}

resource "azurerm_resource_group" "rg2" {
  count    = "${local.preview}"
  name     = "${var.asp_rg}"
  location = "${var.location}"

  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
    
  # On creation, resource group is not ready without delay.
  provisioner "local-exec" {
    command = "sleep 120"
    on_failure = "continue"
  }
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.json")}"
}

# Create Application Insights for the service only if an instrumentation key to a specific instance wasn't provided
resource "azurerm_application_insights" "appinsights" {
  count = "${var.appinsights_instrumentation_key == "" ? 1 : 0}"

  name                = "${var.product}-appinsights-${var.env}${var.deployment_target}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${local.resource_group_name}"
  application_type    = "${var.application_type}"

  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
}

locals {
  # https://www.terraform.io/upgrade-guides/0-11.html#referencing-attributes-from-resources-with-count-0
  service_app_insights_instrumentation_key   = "${element(concat(azurerm_application_insights.appinsights.*.instrumentation_key, list("")), 0)}"
  effective_app_insights_instrumentation_key = "${var.appinsights_instrumentation_key == "" ? local.service_app_insights_instrumentation_key : var.appinsights_instrumentation_key}"

  app_settings_evaluated = {
    APPLICATION_INSIGHTS_IKEY = "${local.effective_app_insights_instrumentation_key}"

    # Support for nodejs apps (java apps to migrate to this env var in future PR)
    APPINSIGHTS_INSTRUMENTATIONKEY = "${local.effective_app_insights_instrumentation_key}"

    # Value used in the spring boot starter.
    AZURE_APPLICATIONINSIGHTS_INSTRUMENTATIONKEY = "${local.effective_app_insights_instrumentation_key}"
  }
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  count               = "${var.enable_ase}"
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.product}-${var.env}${var.deployment_target}-webapp"
  resource_group_name = "${local.resource_group_name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                   = "${var.product}-${var.env}${var.deployment_target}"
    location               = "${var.location}"
    env                    = "${var.env}${var.deployment_target}"
    app_settings           = "${jsonencode(merge(local.production_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    staging_app_settings   = "${jsonencode(merge(var.staging_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings))}"
    additional_host_name   = "${var.additional_host_name}"
    stagingSlotName        = "${var.staging_slot_name}"
    is_frontend            = "${var.is_frontend}"
    https_only             = "${var.https_only}"
    capacity               = "${var.capacity}"
    instance_size          = "${var.instance_size}"
    web_sockets_enabled    = "${var.web_sockets_enabled}"
    asp_name               = "${local.asp_name}"
    asp_rg                 = "${local.asp_rg}"
    teamName               = "${lookup(var.common_tags, "Team Name")}"
    java_version           = "${var.java_version}"
    java_container_type    = "${var.java_container_type}"
    java_container_version = "${var.java_container_version}"
  }
}

data "template_file" "ssltemplate" {
  template = "${file("${path.module}/templates/app-ssl.json")}"
}

resource "azurerm_template_deployment" "app_service_ssl" {
  count = "${var.certificate_name == "" ? 0 : 1 * var.enable_ase}"

  template_body       = "${data.template_file.ssltemplate.rendered}"
  name                = "${var.product}-${var.env}${var.deployment_target}-cert"
  resource_group_name = "${local.resource_group_name}"
  deployment_mode     = "Incremental"

  parameters = {
    name = "${var.product}-${var.env}${var.deployment_target}"

    asp_name = "${local.asp_name}"
    asp_rg   = "${local.asp_rg}"

    certificate_name = "${var.certificate_name}"
    key_vault_id     = "${var.certificate_key_vault_id}"
    hostname         = "${var.additional_host_name}"
  }

  depends_on = ["azurerm_template_deployment.app_service_site"]
}

resource "null_resource" "azcli_exec" {
  count = "${var.enable_ase ? 0 : 1}"

  triggers {
    force_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "env AZURE_CONFIG_DIR=/opt/jenkins/.azure-${var.subscription} az webapp delete --name ${var.product}-${var.env} --resource-group ${local.resource_group_name}"
  }
}
