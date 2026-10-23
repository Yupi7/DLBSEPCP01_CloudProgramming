resource "azurerm_resource_group" "main" {
  name     = "rg-cloudprogramming-dev"
  location = "West Europe"

  tags = {
    project     = "Cloud Programming"
    environment = "Development"
    managed_by  = "Terraform"
  }
}
