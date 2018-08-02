output "webapp_name" {
  value = "${azurerm_template_deployment.app_service_site.name}"
}

output "gitendpoint" {
  value = "I AM DEPRECATED! PLEASE REMOVE ALL REFERENCES TO module.<WEB_APP>.gitendpoint!"
}

output "url" {
  value = "http://${azurerm_template_deployment.app_service_site.name}.service.internal"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.rg.name}"
}
