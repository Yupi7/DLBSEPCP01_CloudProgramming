resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "Terraform"
  }
}

resource "azurerm_linux_web_app" "this" {
  name                = var.web_app_name
  resource_group_name = var.resource_group_name
  location            = azurerm_service_plan.this.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only              = true
  client_affinity_enabled = false

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  zip_deploy_file = "${path.root}/../website/app.zip"

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    REGION_LABEL             = var.location
  }

  site_config {
    always_on                         = true
    minimum_tls_version               = "1.2"
    ftps_state                        = "Disabled"
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    app_command_line                  = "node server.js"

    application_stack {
      node_version = "24-lts"
    }
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    region_role = var.region_role
    managed_by  = "Terraform"
  }
}

resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "autoscale-cloudprogramming-${var.region_role == "Primary" ? "frc" : "swc"}"
  resource_group_name = var.resource_group_name
  location            = azurerm_service_plan.this.location
  target_resource_id  = azurerm_service_plan.this.id
  enabled             = true

  profile {
    name = "cpu-autoscale"

    capacity {
      default = var.autoscale_default
      minimum = var.autoscale_minimum
      maximum = var.autoscale_maximum
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        metric_namespace   = "Microsoft.Web/serverfarms"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        metric_namespace   = "Microsoft.Web/serverfarms"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "Terraform"
  }
}
