resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_service_plan" "france_central" {
  name                = "asp-cloudprogramming-frc"
  resource_group_name = azurerm_resource_group.main.name
  location            = "France Central"
  os_type             = "Linux"
  sku_name            = "S1"

  tags = {
    project     = "Cloud Programming"
    environment = "Development"
    managed_by  = "Terraform"
  }
}

resource "azurerm_service_plan" "sweden_central" {
  name                = "asp-cloudprogramming-swc"
  resource_group_name = azurerm_resource_group.main.name
  location            = "Sweden Central"
  os_type             = "Linux"
  sku_name            = "S1"

  tags = {
    project     = "Cloud Programming"
    environment = "Development"
    managed_by  = "Terraform"
  }
}

resource "azurerm_linux_web_app" "france_central" {
  name                = "cp-web-frc-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.france_central.location
  service_plan_id     = azurerm_service_plan.france_central.id

  https_only              = true
  client_affinity_enabled = false

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  zip_deploy_file = "${path.module}/../website/app.zip"

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    REGION_LABEL             = "France Central"
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
    project     = "Cloud Programming"
    environment = "Development"
    region_role = "Primary"
    managed_by  = "Terraform"
  }
}

resource "azurerm_linux_web_app" "sweden_central" {
  name                = "cp-web-swc-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.sweden_central.location
  service_plan_id     = azurerm_service_plan.sweden_central.id

  https_only              = true
  client_affinity_enabled = false

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  zip_deploy_file = "${path.module}/../website/app.zip"

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    REGION_LABEL             = "Sweden Central"
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
    project     = "Cloud Programming"
    environment = "Development"
    region_role = "Secondary"
    managed_by  = "Terraform"
  }
}
