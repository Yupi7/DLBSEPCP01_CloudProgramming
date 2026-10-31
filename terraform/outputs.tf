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
  value       = module.france_central.web_app_url
}

output "sweden_central_web_app_url" {
  description = "Direkte URL der Web App in Sweden Central"
  value       = module.sweden_central.web_app_url
}

output "traffic_manager_fqdn" {
  description = "Globaler DNS-Endpunkt des Azure Traffic Managers"
  value       = azurerm_traffic_manager_profile.main.fqdn
}
