resource "azurerm_linux_webapp" "linux_web_app" {
  count = var.os_type == "linux" ? 1 : 0

  name                      = local.effective_webapp_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = var.service_plan_id
  https_only                = true
  virtual_network_subnet_id = var.virtual_network_subnet_id

  app_settings = var.app_settings

  site_config {
    http2_enabled                     = var.is_frontend ? null : true
    minimum_tls_version               = var.is_frontend ? null : "1.2"
    health_check_path                 = var.is_frontend ? null : var.health_check_path
    health_check_eviction_time_in_min = var.is_frontend ? null : var.health_check_eviction_time_in_min

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }

    dynamic "cors" {
      for_each = var.is_frontend ? [] : [1]
      content {
        allowed_origins     = ["https://${local.frontend_hostname}", var.custom_domain_url]
        support_credentials = true
      }
    }
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = var.is_frontend ? "RedirectToLoginPage" : "Return401"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = var.auth_client_id
      tenant_auth_endpoint       = var.auth_tenant_endpoint
      client_secret_setting_name = var.auth_client_secret_setting_name
      login_parameters = {
        scope = var.auth_scopes
      }
    }

    login {
      token_store_enabled            = true
      token_refresh_extension_time   = 168
      allowed_external_redirect_urls = var.allowed_external_redirect_urls
    }
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 100
      }
    }

  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack,
    ]
  }
}

resource "azurerm_windows_webapp" "windows_web_app" {
  count = var.os_type == "windows" ? 1 : 0

  name                      = local.effective_webapp_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = var.service_plan_id
  https_only                = true
  virtual_network_subnet_id = var.virtual_network_subnet_id

  app_settings = var.app_settings

  site_config {
    http2_enabled                     = var.is_frontend ? null : true
    minimum_tls_version               = var.is_frontend ? null : "1.2"
    health_check_path                 = var.is_frontend ? null : var.health_check_path
    health_check_eviction_time_in_min = var.is_frontend ? null : var.health_check_eviction_time_in_min

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }

    dynamic "cors" {
      for_each = var.is_frontend ? [] : [1]
      content {
        allowed_origins     = ["https://${local.frontend_hostname}", var.custom_domain_url]
        support_credentials = true
      }
    }
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = var.is_frontend ? "RedirectToLoginPage" : "Return401"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = var.auth_client_id
      tenant_auth_endpoint       = var.auth_tenant_endpoint
      client_secret_setting_name = var.auth_client_secret_setting_name
      login_parameters = {
        scope = var.auth_scopes
      }
    }

    login {
      token_store_enabled            = true
      token_refresh_extension_time   = 168
      allowed_external_redirect_urls = var.allowed_external_redirect_urls
    }
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 100
      }
    }

  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack,
    ]
  }
}
