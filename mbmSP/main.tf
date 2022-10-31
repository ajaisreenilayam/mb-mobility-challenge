resource "azuread_application" "ghActionMbmChallenge" {
  display_name = var.azureADApp
}

resource "azuread_service_principal" "auth" {
  application_id = azuread_application.ghActionMbmChallenge.application_id
}

resource "random_string" "password" {
  length           = 50
  special          = true
  override_special = "/@\" "
}

resource "azuread_service_principal_password" "auth" {
  service_principal_id = azuread_service_principal.auth.id
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "auth" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.auth.id
}

#Useful Information for configuring the github actions secret
#Secret name	            The Secret value
#============================================
#AZURE_CREDENTIALS	        The entire JSON output from the az ad sp create-for-rbac command
#service_principal	        The value of <clientId>
#service_principal_password	The value of <clientSecret>
#subscription	            The value of <subscriptionId>
#tenant	                    The value of <tenantId>
#registry	                The name of your registry
#repository	                azuredocs
#resource_group	            The name of your resource group
#cluster_name	            The name of your cluster