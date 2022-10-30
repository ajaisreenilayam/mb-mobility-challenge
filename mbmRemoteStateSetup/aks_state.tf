resource "azurerm_resource_group" "mbmTerraformBackend" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment           = "mbm-challenge"
    created_by              = "local_terraform_state"
    manual_delete_allowed = "yes_after_aks_deletion"
  }
}

resource "azurerm_storage_account" "mbmStorageAccount" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.mbmTerraformBackend.name
  location                 = azurerm_resource_group.mbmTerraformBackend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment           = "mbm-challenge"
    created_by              = "local_terraform_state"
    manual_delete_allowed = "yes_after_aks_deletion"
  }
}

resource "azurerm_storage_container" "mbmStorageContainer" {
  name                  = var.storage_container
  storage_account_name  = azurerm_storage_account.mbmStorageAccount.name
  container_access_type = "private"
}