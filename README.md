# cnp-module-webapp

A Terraform module that creates an Azure Linux or Windows Web App with opinionated security defaults, Azure AD authentication, optional diagnostics streaming to Event Hub, and an optional private endpoint.

## Resources created

| Resource                             | Description                                    |
| ------------------------------------ | ---------------------------------------------- |
| `azurerm_linux_web_app`              | Created when `os_type = "linux"`               |
| `azurerm_windows_web_app`            | Created when `os_type = "windows"`             |
| `azurerm_monitor_diagnostic_setting` | Created when `diagnostics_enabled = true`      |
| `azurerm_private_endpoint`           | Created when `private_endpoint_enabled = true` |

## Usage

### Frontend web app

A frontend app redirects unauthenticated users to the Azure AD login page. Set `unauthenticated_action = "RedirectToLoginPage"` and supply the redirect URLs your app needs. You may also want to set `http2_enabled`, `minimum_tls_version`, and `health_check_path` to `null` if you don't need them.

```terraform
module "frontend" {
  source = "git@github.com:hmcts/cnp-module-webapp?ref=master"

  product             = "my-product"
  env                 = "dev"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "linux"
  service_plan_id     = azurerm_service_plan.plan.id

  virtual_network_subnet_id = azurerm_subnet.webapp.id

  docker_image_name   = "myregistry.azurecr.io/my-frontend:latest"
  docker_registry_url = "https://myregistry.azurecr.io"

  app_settings = {
    MY_SETTING = "my-value"
  }

  unauthenticated_action            = "RedirectToLoginPage"
  http2_enabled                     = false

  auth_client_id       = var.auth_client_id
  auth_tenant_endpoint = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"

  allowed_external_redirect_urls = [
    "https://my-product-dev.example.com",
    "https://my-product-dev.example.com/",
  ]
}
```

### Backend web app

A backend app returns `401 Unauthorized` for unauthenticated requests (the default). By default, HTTP/2, TLS 1.2 enforcement, a health check endpoint, and CORS (when origins are provided) are all configured.

```terraform
module "backend" {
  source = "git@github.com:hmcts/cnp-module-webapp?ref=master"

  product             = "my-product"
  env                 = "dev"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "linux"
  service_plan_id     = azurerm_service_plan.plan.id

  virtual_network_subnet_id = azurerm_subnet.webapp.id

  docker_image_name   = "myregistry.azurecr.io/my-api:latest"
  docker_registry_url = "https://myregistry.azurecr.io"

  app_settings = {
    MY_SETTING = "my-value"
  }

  unauthenticated_action            = "Return401"
  http2_enabled                     = true
  health_check_path                 = "/health"
  health_check_eviction_time_in_min = 2

  auth_client_id       = var.auth_client_id
  auth_tenant_endpoint = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"

	allowed_external_redirect_urls = [
    "https://my-product-dev.example.com",
    "https://my-product-dev.example.com/",
  ]

  cors_allowed_origins = [
    "https://my-product-dev.example.com",
    "https://my-product-dev-webapp.azurewebsites.net",
  ]
}
```

When no `webapp_name` is supplied the name defaults to `<product>-<env>-webapp`.

## Variables

### Required

| Name                        | Type          | Description                                                                                           |
| --------------------------- | ------------- | ----------------------------------------------------------------------------------------------------- |
| `product`                   | `string`      | Name of the product or service. Used to derive the default web app name.                              |
| `env`                       | `string`      | Environment name (e.g. `dev`, `staging`, `prod`). Used to derive the default web app name.            |
| `resource_group_name`       | `string`      | Name of the resource group to deploy into.                                                            |
| `os_type`                   | `string`      | Type of web app to create. Must be `linux` or `windows`.                                              |
| `service_plan_id`           | `string`      | Resource ID of the App Service Plan to host the web app on.                                           |
| `virtual_network_subnet_id` | `string`      | Resource ID of the subnet for VNet integration.                                                       |
| `docker_image_name`         | `string`      | Docker image to deploy, in `repository/image:tag` format.                                             |
| `docker_registry_url`       | `string`      | URL of the Docker registry (e.g. `https://myregistry.azurecr.io`).                                    |
| `app_settings`              | `map(string)` | Application settings passed to the web app at runtime.                                                |
| `auth_client_id`            | `string`      | Client ID of the Azure AD app registration used for authentication.                                   |
| `auth_tenant_endpoint`      | `string`      | Tenant endpoint for Azure AD authentication (e.g. `https://login.microsoftonline.com/<tenant>/v2.0`). |

### Optional

| Name                                | Type           | Default                                      | Description                                                                                                  |
| ----------------------------------- | -------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `webapp_name`                       | `string`       | `""`                                         | Override the web app name. Defaults to `<product>-<env>-webapp`.                                             |
| `location`                          | `string`       | `"UK South"`                                 | Azure region to deploy resources into.                                                                       |
| `http2_enabled`                     | `bool`         | `true`                                       | Whether HTTP/2 is enabled. Set to `null` to use the provider default.                                        |
| `minimum_tls_version`               | `string`       | `"1.2"`                                      | Minimum TLS version. Set to `null` to use the provider default.                                              |
| `unauthenticated_action`            | `string`       | `"Return401"`                                | Action for unauthenticated requests. `RedirectToLoginPage`, `Return401`, or `Return403`.                     |
| `auth_client_secret_setting_name`   | `string`       | `"MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"` | Name of the app setting that holds the Azure AD client secret.                                               |
| `auth_scopes`                       | `string`       | `"openid profile email offline_access"`      | Space-separated OAuth scopes to request.                                                                     |
| `allowed_external_redirect_urls`    | `list(string)` | `[]`                                         | Allowed external redirect URLs for the Azure AD auth flow.                                                   |
| `cors_allowed_origins`              | `list(string)` | `[]`                                         | Allowed origins for CORS.                                                                                    |
| `health_check_path`                 | `string`       | `null`                                       | Health check path. Health checks are disabled by default.                                                    |
| `health_check_eviction_time_in_min` | `number`       | `null`                                       | Minutes before an unhealthy instance is evicted. Disabled by default.                                        |
| `diagnostics_enabled`               | `bool`         | `false`                                      | Stream diagnostic logs and metrics to Event Hub.                                                             |
| `eventhub_authorization_rule_id`    | `string`       | `null`                                       | Resource ID of the Event Hub authorisation rule. Required when `diagnostics_enabled = true`.                 |
| `eventhub_name`                     | `string`       | `null`                                       | Name of the Event Hub to stream diagnostics to. Required when `diagnostics_enabled = true`.                  |
| `private_endpoint_enabled`          | `bool`         | `false`                                      | Create a private endpoint for the web app.                                                                   |
| `private_endpoint_subnet_id`        | `string`       | `null`                                       | Resource ID of the subnet to place the private endpoint in. Required when `private_endpoint_enabled = true`. |

## Configuration defaults

The defaults are tuned for backend/API apps. For a frontend app, override the relevant variables:

| Setting                  | Default (backend-style) | Typical frontend override |
| ------------------------ | ----------------------- | ------------------------- |
| `unauthenticated_action` | `Return401`             | `RedirectToLoginPage`     |
| `http2_enabled`          | `true`                  | `null` (provider default) |
| `minimum_tls_version`    | `"1.2"`                 | `null` (provider default) |
| `cors_allowed_origins`   | `[]` (no CORS block)    | `[]` (no CORS block)      |

Health checks (`health_check_path`, `health_check_eviction_time_in_min`) default to `null` (disabled) for all app types.

## Security defaults

Every web app created by this module enforces the following regardless of input variables:

- **HTTPS only** — `https_only = true`
- **Authentication required** — Azure AD v2 auth is always enabled; unauthenticated requests are handled according to `unauthenticated_action`
- **System-assigned managed identity** — enabled on every web app
- **Detailed logging** — application and HTTP logs written to the file system with a 90-day / 100 MB retention policy

## Diagnostics

When `diagnostics_enabled = true` the following log categories and the `AllMetrics` metric category are streamed to the specified Event Hub:

- `AppServiceConsoleLogs`
- `AppServiceAppLogs`
- `AppServiceHTTPLogs`
- `AppServiceAuditLogs`
- `AppServiceIPSecAuditLogs`
- `AppServicePlatformLogs`
- `AppServiceAuthenticationLogs`

## Testing

Tests are written using the native [Terraform test framework](https://developer.hashicorp.com/terraform/language/tests) and live in the `tests/` directory.

```
tests/
  main.tftest.hcl          # all test runs
  modules/
    setup/
      main.tf              # creates shared prerequisite resources (resource group, common tags)
```

Run the tests with:

```bash
terraform test
```

> Tests use `command = plan` and do not create real Azure resources (except the shared resource group created by the `setup` module run).

### Test coverage

| Run                                                | What is verified                                                                                  |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `linux_webapp_is_created_for_linux_os_type`        | Only a Linux web app is planned when `os_type = "linux"`                                          |
| `windows_webapp_is_created_for_windows_os_type`    | Only a Windows web app is planned when `os_type = "windows"`                                      |
| `default_webapp_name_follows_naming_convention`    | Empty `webapp_name` produces `<product>-<env>-webapp`                                             |
| `custom_webapp_name_overrides_default`             | An explicit `webapp_name` is used verbatim                                                        |
| `https_only_is_enforced_on_linux_webapp`           | `https_only = true` on the Linux web app                                                          |
| `https_only_is_enforced_on_windows_webapp`         | `https_only = true` on the Windows web app                                                        |
| `system_assigned_identity_on_linux_webapp`         | `SystemAssigned` managed identity on the Linux web app                                            |
| `system_assigned_identity_on_windows_webapp`       | `SystemAssigned` managed identity on the Windows web app                                          |
| `diagnostics_not_created_when_disabled_by_default` | No diagnostic setting created by default                                                          |
| `diagnostics_created_for_linux_when_enabled`       | Diagnostic setting created for Linux when `diagnostics_enabled = true`                            |
| `diagnostics_created_for_windows_when_enabled`     | Diagnostic setting created for Windows when `diagnostics_enabled = true`                          |
| `private_endpoint_not_created_by_default`          | No private endpoint created by default                                                            |
| `linux_private_endpoint_created_when_enabled`      | Linux private endpoint planned when `os_type = "linux"` and `private_endpoint_enabled = true`     |
| `windows_private_endpoint_created_when_enabled`    | Windows private endpoint planned when `os_type = "windows"` and `private_endpoint_enabled = true` |
| `default_uses_return_401_unauthenticated_action`   | `unauthenticated_action` defaults to `"Return401"`                                                |
| `redirect_to_login_unauthenticated_action`         | `unauthenticated_action = "RedirectToLoginPage"` when explicitly set                              |
| `health_check_configured_when_path_supplied`       | `health_check_path` and `health_check_eviction_time_in_min` applied when explicitly supplied      |
| `health_check_is_null_by_default`                  | `health_check_path` is `null` by default                                                          |
| `default_has_cors_configured`                      | A CORS block is present when `cors_allowed_origins` is provided                                   |
| `no_cors_block_when_origins_empty`                 | No CORS block when `cors_allowed_origins` is empty                                                |

## Terraform

Requires Terraform `>= 1.5`. Provider requirements:

| Provider            | Version   |
| ------------------- | --------- |
| `hashicorp/azurerm` | `~> 4.62` |
| `hashicorp/null`    | `~> 3.2`  |
