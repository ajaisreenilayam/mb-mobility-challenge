resource "azuread_application" "ghActionMbmChallenge" {
  display_name = var.azureADApp
}

resource "azuread_service_principal" "auth" {
  application_id = azuread_application.ghActionMbmChallenge.application_id
}

resource "random_string" "password" {
length           = 5
  special          = false
  #override_special = "/@\" "
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
#
#{
#"clientId": "f318e148-9af6-4553-8f0c-20faf9d5f136",
#"clientSecret": "Jq28Q~Bs4wDNbL45tyU1qIuMhX_yMoTsqdKyqdl9",
#"subscriptionId": "c1e45c6c-1ab0-4ebd-a77f-40b2316b9eaa",
#"tenantId": "685d03de-e19c-4a6e-b0a7-fbab876c38ae",
#"activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
#"resourceManagerEndpointUrl": "https://management.azure.com/",
#"activeDirectoryGraphResourceId": "https://graph.windows.net/",
#"sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
#"galleryEndpointUrl": "https://gallery.azure.com/",
#"managementEndpointUrl": "https://management.core.windows.net/"
#}
