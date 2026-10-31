resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "Terraform"
  }
}
