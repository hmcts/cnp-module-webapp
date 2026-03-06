output "common_tags" {
  description = "Common tags to apply to resources."
  value       = module.common_tags.common_tags
}

output "resource_group_name" {
  description = "Name of the test resource group."
  value       = azurerm_resource_group.test_rg.name
}
