output "resource_group_name" {
  description = "Name der durch Terraform erstellten Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Azure-Region der Resource Group"
  value       = azurerm_resource_group.main.location
}

output "france_central_web_app_url" {
  description = "Direkte URL der Web App in France Central"
  value       = "https://${azurerm_linux_web_app.france_central.default_hostname}"
}

output "sweden_central_web_app_url" {
  description = "Direkte URL der Web App in Sweden Central"
  value       = "https://${azurerm_linux_web_app.sweden_central.default_hostname}"
}
