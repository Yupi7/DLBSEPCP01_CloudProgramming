resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-cloudprogramming-${random_id.suffix.hex}"
  location            = "France Central"
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
  target_resource_id         = azurerm_linux_web_app.france_central.id
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
  target_resource_id         = azurerm_linux_web_app.sweden_central.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
}
