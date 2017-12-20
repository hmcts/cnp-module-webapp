output "webapp_name" {
  value = "${azurerm_template_deployment.app_service_site.name}"
}

output "gitendpoint" {
  value = "${azurerm_template_deployment.app_service_site.name}.scm.service.core-compute-prod.internal/${azurerm_template_deployment.app_service_site.name}.git"
}

output "url" {
  value = "http://${azurerm_template_deployment.app_service_site.name}.service.internal"
}
