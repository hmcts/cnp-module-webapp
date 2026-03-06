locals {
  default_resource_group_name = "${var.product}-${var.env}${var.deployment_target}"
  resource_group_name         = var.resource_group_name != "" ? var.resource_group_name : local.default_resource_group_name

  production_slot_app_settings = {
    SLOT                         = "PRODUCTION"
    WEBSITE_LOCAL_CACHE_OPTION   = "${var.website_local_cache_sizeinmb == "0" ? "Never" : "Always"}"
    WEBSITE_LOCAL_CACHE_SIZEINMB = "${var.website_local_cache_sizeinmb}"
  }

  asp_name = var.asp_name != "null" ? var.asp_name : local.default_resource_group_name
  asp_rg   = var.asp_rg != "null" ? var.asp_rg : local.default_resource_group_name
  sp_name  = var.env != "preview" ? local.asp_name : local.default_resource_group_name
  sp_rg    = var.env != "preview" ? local.asp_rg : local.default_resource_group_name

  preview = var.env != "preview" ? 0 : 1
  envcore = var.deployment_target != "" ? "env" : "core"

  ase_enabled = var.enable_ase ? 1 : 0
  delete_ase  = var.enable_ase ? 0 : 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location

  tags = (merge(var.common_tags,
    { lastUpdated = timestamp() }
  ))
}

resource "azurerm_resource_group" "rg2" {
  count    = local.preview
  name     = var.asp_rg
  location = var.location

  tags = (merge(var.common_tags,
    { lastUpdated = timestamp() }
  ))
}

# Create Application Insights for the service only if an instrumentation key to a specific instance wasn't provided
resource "azurerm_application_insights" "appinsights" {
  count = var.appinsights_instrumentation_key == "" ? 1 : 0

  name                = "${var.product}-appinsights-${var.env}${var.deployment_target}"
  location            = var.appinsights_location
  resource_group_name = local.resource_group_name
  application_type    = var.application_type

  tags = (merge(var.common_tags,
    { lastUpdated = timestamp() }
  ))
}

locals {
  service_app_insights_instrumentation_key   = try(azurerm_application_insights.appinsights[0].instrumentation_key, "")
  effective_app_insights_instrumentation_key = var.appinsights_instrumentation_key == "" ? local.service_app_insights_instrumentation_key : var.appinsights_instrumentation_key

  app_settings_evaluated = {
    APPLICATION_INSIGHTS_IKEY = "${local.effective_app_insights_instrumentation_key}"

    # Support for nodejs apps (java apps to migrate to this env var in future PR)
    APPINSIGHTS_INSTRUMENTATIONKEY = "${local.effective_app_insights_instrumentation_key}"

    # Value used in the spring boot starter.
    AZURE_APPLICATIONINSIGHTS_INSTRUMENTATIONKEY = "${local.effective_app_insights_instrumentation_key}"
  }
}

# Create Application Service site
resource "azurerm_service_plan" "app_service_plan" {
  count               = local.ase_enabled
  name                = local.asp_name
  location            = var.location
  resource_group_name = local.asp_rg
  os_type             = "Windows"
  sku_name            = var.instance_size
  worker_count        = tonumber(var.capacity)

  app_service_environment_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.asp_rg}/providers/Microsoft.Web/hostingEnvironments/core-compute-${var.env}${var.deployment_target}"
}

resource "azurerm_windows_web_app" "app_service_site" {
  count               = local.ase_enabled
  name                = "${var.product}-${var.env}${var.deployment_target}"
  location            = var.location
  resource_group_name = local.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan[0].id

  app_settings = merge(local.production_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings)

  sticky_settings {
    app_setting_names = [
      "SLOT",
      "WEBSITE_LOCAL_CACHE_OPTION",
      "WEBSITE_LOCAL_CACHE_SIZEINMB"
    ]
  }

  site_config {
    always_on                      = true
    use_32_bit_worker              = false
    websockets_enabled             = var.web_sockets_enabled == "true"
    detailed_error_logging_enabled = true

    application_stack {
      current_stack  = "java"
      java_version   = var.java_version
      tomcat_version = var.tomcat_version
    }
  }

  client_affinity_enabled = false
  https_only              = var.https_only == "true"
}

resource "azurerm_windows_web_app_slot" "app_service_slot" {
  count          = local.ase_enabled
  name           = var.staging_slot_name
  app_service_id = azurerm_windows_web_app.app_service_site[0].id

  app_settings = merge(var.staging_slot_app_settings, var.app_settings_defaults, local.app_settings_evaluated, var.app_settings)

  site_config {
    always_on                      = true
    use_32_bit_worker              = false
    websockets_enabled             = var.web_sockets_enabled == "true"
    detailed_error_logging_enabled = true

    application_stack {
      current_stack  = "java"
      java_version   = var.java_version
      tomcat_version = var.tomcat_version
    }
  }

  client_affinity_enabled = false
  https_only              = var.https_only == "true"
}

resource "azurerm_app_service_custom_hostname_binding" "tm_host" {
  count = local.ase_enabled == 1 && !contains(["", "null", "false"], var.additional_host_name) ? 1 : 0

  hostname            = "tm${var.additional_host_name}"
  app_service_name    = azurerm_windows_web_app.app_service_site[0].name
  resource_group_name = local.resource_group_name
}

resource "azurerm_app_service_custom_hostname_binding" "additional_host" {
  count = local.ase_enabled == 1 && !contains(["", "null", "false"], var.additional_host_name) ? 1 : 0

  hostname            = var.additional_host_name
  app_service_name    = azurerm_windows_web_app.app_service_site[0].name
  resource_group_name = local.resource_group_name

  depends_on = [azurerm_app_service_custom_hostname_binding.tm_host]
}

resource "azurerm_app_service_custom_hostname_binding" "traffic_manager_host" {
  count = local.ase_enabled == 1 && !contains(["", "null", "false"], var.additional_host_name) ? 1 : 0

  hostname            = "hmcts-${var.product}-${var.env}${var.deployment_target}.trafficmanager.net"
  app_service_name    = azurerm_windows_web_app.app_service_site[0].name
  resource_group_name = local.resource_group_name

  depends_on = [azurerm_app_service_custom_hostname_binding.additional_host]
}

data "azurerm_client_config" "current" {}

resource "azurerm_app_service_certificate" "app_service_ssl" {
  count = var.certificate_name == "" ? 0 : 1 * local.ase_enabled

  name                = var.certificate_name
  resource_group_name = local.resource_group_name
  location            = var.location
  key_vault_secret_id = "${var.certificate_key_vault_id}/secrets/${var.certificate_name}"

  depends_on = [azurerm_windows_web_app.app_service_site]
}

resource "azurerm_app_service_certificate_binding" "app_service_ssl" {
  count = var.certificate_name == "" ? 0 : 1 * local.ase_enabled

  hostname_binding_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Web/sites/${var.product}-${var.env}${var.deployment_target}/hostNameBindings/${var.additional_host_name}"
  certificate_id      = azurerm_app_service_certificate.app_service_ssl[0].id
  ssl_state           = "SniEnabled"

  depends_on = [azurerm_app_service_certificate.app_service_ssl, azurerm_app_service_custom_hostname_binding.additional_host]
}

resource "null_resource" "azcli_exec" {
  count = local.delete_ase

  triggers = {
    force_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "env AZURE_CONFIG_DIR=/opt/jenkins/.azure-${var.subscription} az webapp delete --name ${var.product}-${var.env} --resource-group ${local.resource_group_name} || true"
  }
}
