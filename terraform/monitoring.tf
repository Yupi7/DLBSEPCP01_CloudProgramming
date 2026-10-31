resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-cloudprogramming-${random_id.suffix.hex}"
  location            = var.france_central_location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    project     = "Cloud Programming"
    environment = "Development"
    managed_by  = "Terraform"
  }
}

resource "azurerm_monitor_diagnostic_setting" "france_central" {
  name                       = "diag-cloudprogramming-frc"
  target_resource_id         = module.france_central.web_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
}

resource "azurerm_monitor_diagnostic_setting" "sweden_central" {
  name                       = "diag-cloudprogramming-swc"
  target_resource_id         = module.sweden_central.web_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
}
