
# Create a resource group
resource "azurerm_resource_group" "storage_rg" {
  name     = var.azure_storage_resourcegroup_name
  location = "eastus"
}

# Create Azure Storage Account required for Function App
resource azurerm_storage_account "st_account" {
  name                     = var.azure_storage_account_name
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource azurerm_storage_container "container" {
  name                  = var.azure_storage_bucket_name
  storage_account_name  = azurerm_storage_account.st_account.name
  container_access_type = "private"
}