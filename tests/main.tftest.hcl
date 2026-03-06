provider "azurerm" {
  features {}
  subscription_id = "3eec5bde-7feb-4566-bfb6-805df6e10b90"
}

# Shared defaults for all runs. Dummy ARM resource IDs are acceptable here
# because every test run uses command = plan and does not apply real resources.
variables {
  env                             = "test"
  product                         = "cnp-module-webapp-tests"
  resource_group_name             = "cnp-module-webapp-tests-rg"
  webapp_name                     = ""
  os_type                         = "linux"
  service_plan_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/test-plan"
  virtual_network_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/webapp-subnet"
  docker_image_name               = "nginx:latest"
  docker_registry_url             = "https://registry.hub.docker.com"
  app_settings                    = {}
  auth_client_id       = "00000000-0000-0000-0000-000000000000"
  auth_tenant_endpoint = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
}

# Creates the shared resource group used by all apply-stage setup.
run "setup" {
  module {
    source = "./tests/modules/setup"
  }
}

# ----------------------------------------------------------------------------
# os_type routing
# ----------------------------------------------------------------------------

run "linux_webapp_is_created_for_linux_os_type" {
  command = plan

  assert {
    condition     = length(azurerm_linux_webapp.linux_web_app) == 1
    error_message = "Expected exactly one Linux web app to be planned when os_type is 'linux'."
  }

  assert {
    condition     = length(azurerm_windows_webapp.windows_web_app) == 0
    error_message = "Expected no Windows web app to be planned when os_type is 'linux'."
  }
}

run "windows_webapp_is_created_for_windows_os_type" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = length(azurerm_windows_webapp.windows_web_app) == 1
    error_message = "Expected exactly one Windows web app to be planned when os_type is 'windows'."
  }

  assert {
    condition     = length(azurerm_linux_webapp.linux_web_app) == 0
    error_message = "Expected no Linux web app to be planned when os_type is 'windows'."
  }
}

# ----------------------------------------------------------------------------
# Naming
# ----------------------------------------------------------------------------

run "default_webapp_name_follows_naming_convention" {
  command = plan

  variables {
    webapp_name = ""
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].name == "cnp-module-webapp-tests-test-webapp"
    error_message = "Expected the default web app name to follow the pattern '<product>-<env>-webapp'."
  }
}

run "custom_webapp_name_overrides_default" {
  command = plan

  variables {
    webapp_name = "my-custom-webapp"
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].name == "my-custom-webapp"
    error_message = "Expected the web app name to equal the explicitly supplied webapp_name."
  }
}

# ----------------------------------------------------------------------------
# Security defaults
# ----------------------------------------------------------------------------

run "https_only_is_enforced_on_linux_webapp" {
  command = plan

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].https_only == true
    error_message = "Expected https_only to be true on the Linux web app."
  }
}

run "https_only_is_enforced_on_windows_webapp" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = azurerm_windows_webapp.windows_web_app[0].https_only == true
    error_message = "Expected https_only to be true on the Windows web app."
  }
}

run "system_assigned_identity_on_linux_webapp" {
  command = plan

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].identity[0].type == "SystemAssigned"
    error_message = "Expected the Linux web app to have a SystemAssigned managed identity."
  }
}

run "system_assigned_identity_on_windows_webapp" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = azurerm_windows_webapp.windows_web_app[0].identity[0].type == "SystemAssigned"
    error_message = "Expected the Windows web app to have a SystemAssigned managed identity."
  }
}

# ----------------------------------------------------------------------------
# Diagnostics
# ----------------------------------------------------------------------------

run "diagnostics_not_created_when_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.linux_web_app_diagnostics) == 0
    error_message = "Expected no diagnostics setting when diagnostics_enabled is false (the default)."
  }
}

run "diagnostics_created_for_linux_when_enabled" {
  command = plan

  variables {
    os_type             = "linux"
    diagnostics_enabled = true
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.linux_web_app_diagnostics) == 1
    error_message = "Expected a diagnostics setting to be created for the Linux web app when diagnostics_enabled is true."
  }
}

run "diagnostics_created_for_windows_when_enabled" {
  command = plan

  variables {
    os_type             = "windows"
    diagnostics_enabled = true
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.windows_web_app_diagnostics) == 1
    error_message = "Expected a diagnostics setting to be created for the Windows web app when diagnostics_enabled is true."
  }
}

# ----------------------------------------------------------------------------
# Private endpoint
# ----------------------------------------------------------------------------

run "private_endpoint_not_created_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_private_endpoint.webapp_private_endpoint) == 0
    error_message = "Expected no private endpoint to be created when private_endpoint_enabled is false (the default)."
  }
}

run "private_endpoint_created_when_enabled" {
  command = plan

  variables {
    private_endpoint_enabled   = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe-subnet"
  }

  assert {
    condition     = length(azurerm_private_endpoint.webapp_private_endpoint) == 1
    error_message = "Expected a private endpoint to be created when private_endpoint_enabled is true."
  }
}

# ----------------------------------------------------------------------------
# is_frontend auth behaviour
# ----------------------------------------------------------------------------

run "backend_uses_return_401_unauthenticated_action" {
  command = plan

  # is_frontend defaults to false

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].auth_settings_v2[0].unauthenticated_action == "Return401"
    error_message = "Expected unauthenticated_action to be 'Return401' for a backend (non-frontend) web app."
  }
}

run "frontend_uses_redirect_to_login_unauthenticated_action" {
  command = plan

  variables {
    is_frontend = true
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].auth_settings_v2[0].unauthenticated_action == "RedirectToLoginPage"
    error_message = "Expected unauthenticated_action to be 'RedirectToLoginPage' for a frontend web app."
  }
}

# ----------------------------------------------------------------------------
# is_frontend site_config behaviour
# ----------------------------------------------------------------------------

run "backend_has_health_check_configured" {
  command = plan

  variables {
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].site_config[0].health_check_path == "/health"
    error_message = "Expected health_check_path to be '/health' for a backend web app."
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].site_config[0].health_check_eviction_time_in_min == 2
    error_message = "Expected health_check_eviction_time_in_min to be 2 for a backend web app."
  }
}

run "frontend_has_no_health_check" {
  command = plan

  variables {
    is_frontend = true
  }

  assert {
    condition     = azurerm_linux_webapp.linux_web_app[0].site_config[0].health_check_path == null
    error_message = "Expected health_check_path to be null for a frontend web app."
  }
}

run "backend_has_cors_configured" {
  command = plan

  variables {
    custom_domain_url = "https://my-custom-domain.example.com"
  }

  assert {
    condition     = length(azurerm_linux_webapp.linux_web_app[0].site_config[0].cors) == 1
    error_message = "Expected a CORS block to be configured for a backend web app."
  }
}

run "frontend_has_no_cors_block" {
  command = plan

  variables {
    is_frontend = true
  }

  assert {
    condition     = length(azurerm_linux_webapp.linux_web_app[0].site_config[0].cors) == 0
    error_message = "Expected no CORS block for a frontend web app."
  }
}