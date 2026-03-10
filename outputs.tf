output "webapp_name" {
  description = "The name of the web app."
  value       = local.effective_webapp_name
}

output "webapp_id" {
  description = "The resource ID of the web app."
  value       = var.os_type == "linux" ? azurerm_linux_web_app.linux_web_app[0].id : azurerm_windows_web_app.windows_web_app[0].id
}

output "webapp_default_hostname" {
  description = "The default hostname of the web app (*.azurewebsites.net)."
  value       = var.os_type == "linux" ? azurerm_linux_web_app.linux_web_app[0].default_hostname : azurerm_windows_web_app.windows_web_app[0].default_hostname
}

output "webapp_identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity on the web app."
  value       = var.os_type == "linux" ? azurerm_linux_web_app.linux_web_app[0].identity[0].principal_id : azurerm_windows_web_app.windows_web_app[0].identity[0].principal_id
}

output "private_endpoint_id" {
  description = "The resource ID of the private endpoint, if enabled."
  value       = var.private_endpoint_enabled ? (var.os_type == "linux" ? azurerm_private_endpoint.linux_webapp_private_endpoint[0].id : azurerm_private_endpoint.windows_webapp_private_endpoint[0].id) : null
}
