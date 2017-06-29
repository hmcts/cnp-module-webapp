output "webapp_name" {
  value = "${azurerm_template_deployment.app_service_site.name}"
}
