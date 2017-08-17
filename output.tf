output "webapp_name" {
  value = "${azurerm_template_deployment.app_service_site.name}"
}

output "gitendpoint" {
  value = "${azurerm_template_deployment.app_service_site.name}.scm.${var.asename}.p.azurewebsites.net/${azurerm_template_deployment.app_service_site.name}.git"
}

output "url" {
  value = "http://${azurerm_template_deployment.app_service_site.name}.${var.asename}.p.azurewebsites.net"
}
