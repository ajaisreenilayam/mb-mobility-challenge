output "Storage_Account_name" {
  value = azurerm_storage_account.mbmStorageAccount.name
}
output "Container_Name" {
  value = azurerm_storage_container.mbmStorageContainer.name
}