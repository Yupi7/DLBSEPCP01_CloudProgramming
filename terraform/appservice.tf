resource "random_id" "suffix" {
  byte_length = 3
}

module "france_central" {
  source = "./modules/app-service-region"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.france_central_location

  service_plan_name = "asp-cloudprogramming-frc"
  web_app_name      = "cp-web-frc-${random_id.suffix.hex}"
  region_role       = "Primary"

  project_name    = var.project_name
  environment     = var.environment
  app_service_sku = var.app_service_sku

  autoscale_minimum   = var.autoscale_minimum
  autoscale_default   = var.autoscale_default
  autoscale_maximum   = var.autoscale_maximum
  scale_out_threshold = var.scale_out_threshold
  scale_in_threshold  = var.scale_in_threshold
}

module "sweden_central" {
  source = "./modules/app-service-region"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.sweden_central_location

  service_plan_name = "asp-cloudprogramming-swc"
  web_app_name      = "cp-web-swc-${random_id.suffix.hex}"
  region_role       = "Secondary"

  project_name    = var.project_name
  environment     = var.environment
  app_service_sku = var.app_service_sku

  autoscale_minimum   = var.autoscale_minimum
  autoscale_default   = var.autoscale_default
  autoscale_maximum   = var.autoscale_maximum
  scale_out_threshold = var.scale_out_threshold
  scale_in_threshold  = var.scale_in_threshold
}
