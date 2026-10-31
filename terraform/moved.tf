moved {
  from = azurerm_service_plan.france_central
  to   = module.france_central.azurerm_service_plan.this
}

moved {
  from = azurerm_linux_web_app.france_central
  to   = module.france_central.azurerm_linux_web_app.this
}

moved {
  from = azurerm_monitor_autoscale_setting.france_central
  to   = module.france_central.azurerm_monitor_autoscale_setting.this
}

moved {
  from = azurerm_service_plan.sweden_central
  to   = module.sweden_central.azurerm_service_plan.this
}

moved {
  from = azurerm_linux_web_app.sweden_central
  to   = module.sweden_central.azurerm_linux_web_app.this
}

moved {
  from = azurerm_monitor_autoscale_setting.sweden_central
  to   = module.sweden_central.azurerm_monitor_autoscale_setting.this
}
