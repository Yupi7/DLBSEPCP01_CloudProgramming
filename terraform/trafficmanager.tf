resource "azurerm_traffic_manager_profile" "main" {
  name                   = "tm-cloudprogramming-${random_id.suffix.hex}"
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "tm-cp-${random_id.suffix.hex}"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  tags = {
    project     = "Cloud Programming"
    environment = "Development"
    managed_by  = "Terraform"
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "france_central" {
  name               = "endpoint-france-central"
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = azurerm_linux_web_app.france_central.id
}

resource "azurerm_traffic_manager_azure_endpoint" "sweden_central" {
  name               = "endpoint-sweden-central"
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = azurerm_linux_web_app.sweden_central.id
}
