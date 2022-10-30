terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "mbm.tfstate"
    storage_account_name = "mbmtfstatebackend"
    use_azuread_auth     = true
  }
}
