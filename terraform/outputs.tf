output "resource_group_name" {
  description = "Name der durch Terraform erstellten Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Azure-Region der Resource Group"
  value       = azurerm_resource_group.main.location
}
