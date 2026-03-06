resource "azurerm_private_endpoint" "webapp_private_endpoint" {
  count = var.private_endpoint_enabled ? 1 : 0

  name                = "${var.webapp_name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.webapp_name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_windows_web_app.app_service_site[0].id
    subresource_names              = ["sites"]
  }

}
