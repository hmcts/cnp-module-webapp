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
    condition     = length(azurerm_linux_web_app.linux_web_app) == 1
    error_message = "Expected exactly one Linux web app to be planned when os_type is 'linux'."
  }

  assert {
    condition     = length(azurerm_windows_web_app.windows_web_app) == 0
    error_message = "Expected no Windows web app to be planned when os_type is 'linux'."
  }
}

run "windows_webapp_is_created_for_windows_os_type" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = length(azurerm_windows_web_app.windows_web_app) == 1
    error_message = "Expected exactly one Windows web app to be planned when os_type is 'windows'."
  }

  assert {
    condition     = length(azurerm_linux_web_app.linux_web_app) == 0
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
    condition     = azurerm_linux_web_app.linux_web_app[0].name == "cnp-module-webapp-tests-test-webapp"
    error_message = "Expected the default web app name to follow the pattern '<product>-<env>-webapp'."
  }
}

run "custom_webapp_name_overrides_default" {
  command = plan

  variables {
    webapp_name = "my-custom-webapp"
  }

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].name == "my-custom-webapp"
    error_message = "Expected the web app name to equal the explicitly supplied webapp_name."
  }
}

# ----------------------------------------------------------------------------
# Security defaults
# ----------------------------------------------------------------------------

run "https_only_is_enforced_on_linux_webapp" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].https_only == true
    error_message = "Expected https_only to be true on the Linux web app."
  }
}

run "https_only_is_enforced_on_windows_webapp" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = azurerm_windows_web_app.windows_web_app[0].https_only == true
    error_message = "Expected https_only to be true on the Windows web app."
  }
}

run "system_assigned_identity_on_linux_webapp" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].identity[0].type == "SystemAssigned"
    error_message = "Expected the Linux web app to have a SystemAssigned managed identity."
  }
}

run "system_assigned_identity_on_windows_webapp" {
  command = plan

  variables {
    os_type = "windows"
  }

  assert {
    condition     = azurerm_windows_web_app.windows_web_app[0].identity[0].type == "SystemAssigned"
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
    os_type                        = "linux"
    diagnostics_enabled            = true
    eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/test-namespace/authorizationRules/RootManageSharedAccessKey"
    eventhub_name                  = "test-eventhub"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.linux_web_app_diagnostics) == 1
    error_message = "Expected a diagnostics setting to be created for the Linux web app when diagnostics_enabled is true."
  }
}

run "diagnostics_created_for_windows_when_enabled" {
  command = plan

  variables {
    os_type                        = "windows"
    diagnostics_enabled            = true
    eventhub_authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.EventHub/namespaces/test-namespace/authorizationRules/RootManageSharedAccessKey"
    eventhub_name                  = "test-eventhub"
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
    condition     = length(azurerm_private_endpoint.linux_webapp_private_endpoint) == 0
    error_message = "Expected no Linux private endpoint to be created when private_endpoint_enabled is false (the default)."
  }
}

run "linux_private_endpoint_created_when_enabled" {
  command = plan

  variables {
    os_type                    = "linux"
    private_endpoint_enabled   = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe-subnet"
  }

  assert {
    condition     = length(azurerm_private_endpoint.linux_webapp_private_endpoint) == 1
    error_message = "Expected a Linux private endpoint to be created when os_type is 'linux' and private_endpoint_enabled is true."
  }

  assert {
    condition     = length(azurerm_private_endpoint.windows_webapp_private_endpoint) == 0
    error_message = "Expected no Windows private endpoint when os_type is 'linux'."
  }
}

run "windows_private_endpoint_created_when_enabled" {
  command = plan

  variables {
    os_type                    = "windows"
    private_endpoint_enabled   = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe-subnet"
  }

  assert {
    condition     = length(azurerm_private_endpoint.windows_webapp_private_endpoint) == 1
    error_message = "Expected a Windows private endpoint to be created when os_type is 'windows' and private_endpoint_enabled is true."
  }

  assert {
    condition     = length(azurerm_private_endpoint.linux_webapp_private_endpoint) == 0
    error_message = "Expected no Linux private endpoint when os_type is 'windows'."
  }
}

# ----------------------------------------------------------------------------
# unauthenticated_action behaviour
# ----------------------------------------------------------------------------

run "default_uses_return_401_unauthenticated_action" {
  command = plan

  # unauthenticated_action defaults to "Return401"

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].auth_settings_v2[0].unauthenticated_action == "Return401"
    error_message = "Expected unauthenticated_action to be 'Return401' for a backend (non-frontend) web app."
  }
}

run "redirect_to_login_unauthenticated_action" {
  command = plan

  variables {
    unauthenticated_action = "RedirectToLoginPage"
  }

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].auth_settings_v2[0].unauthenticated_action == "RedirectToLoginPage"
    error_message = "Expected unauthenticated_action to be 'RedirectToLoginPage' when explicitly set."
  }
}

# ----------------------------------------------------------------------------
# site_config behaviour
# ----------------------------------------------------------------------------

run "health_check_configured_when_path_supplied" {
  command = plan

  variables {
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 2
  }

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].site_config[0].health_check_path == "/health"
    error_message = "Expected health_check_path to match the supplied value."
  }

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].site_config[0].health_check_eviction_time_in_min == 2
    error_message = "Expected health_check_eviction_time_in_min to match the supplied value."
  }
}

run "health_check_is_null_by_default" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].site_config[0].health_check_path == null
    error_message = "Expected health_check_path to be null by default."
  }
}

run "default_has_cors_configured" {
  command = plan

  variables {
    cors_allowed_origins = ["https://my-frontend.example.com", "https://my-custom-domain.example.com"]
  }

  assert {
    condition     = length(azurerm_linux_web_app.linux_web_app[0].site_config[0].cors) == 1
    error_message = "Expected a CORS block to be configured for a backend web app."
  }

  assert {
    condition     = azurerm_linux_web_app.linux_web_app[0].site_config[0].cors[0].allowed_origins == toset(["https://my-frontend.example.com", "https://my-custom-domain.example.com"])
    error_message = "Expected CORS allowed_origins to match the supplied cors_allowed_origins."
  }
}

run "no_cors_block_when_origins_empty" {
  command = plan

  assert {
    condition     = length(azurerm_linux_web_app.linux_web_app[0].site_config[0].cors) == 0
    error_message = "Expected no CORS block when cors_allowed_origins is empty."
  }
}