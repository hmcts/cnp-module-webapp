output "webapp_name" {
  value = "${join(" ", azurerm_template_deployment.app_service_site.*.name)}"
}

output "gitendpoint" {
  value = "${join(" ",azurerm_template_deployment.app_service_site.*.name)}.scm.service.core-compute-prod.internal/${join(" ",azurerm_template_deployment.app_service_site.*.name)}.git"
}

output "url" {
  value = "http://${join(" ",azurerm_template_deployment.app_service_site.*.name)}.service.internal}"
}

output "resource_group_name" {
  value = "${local.resource_group_name}"
}
