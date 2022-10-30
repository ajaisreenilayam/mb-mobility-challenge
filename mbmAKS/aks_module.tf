resource "azurerm_resource_group" "mbmRG" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_security_group" "mbmNetworkSecurityGroup" {
  name                = "mbm-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "mbmSecurityRule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "mbm-challenge"
  }
  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azurerm_virtual_network" "mbmVirtualNetwork" {
  name                = "mbmVirtualNetwork"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.52.0.0/16"]
  tags = {
    environment = "mbm-challenge"
  }
  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azurerm_subnet" "mbmsubnet" {
  name                 = "mbmsubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.mbmVirtualNetwork.name
  address_prefixes     = ["10.52.0.0/24"]
  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azurerm_container_registry" "mbmAzureContainerRegistry" {
  name                = "mbmAzureContainerRegistry"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
  depends_on = [azurerm_resource_group.mbmRG]

}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {
}

resource "azuread_application" "mbmApplication" {
  display_name = "mbmApplication"
  owners       = [data.azuread_client_config.current.object_id]
  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azuread_service_principal" "mbmServicePrincipal" {
  application_id               = azuread_application.mbmApplication.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  depends_on = [azurerm_resource_group.mbmRG]
}


resource "azurerm_key_vault" "mbmKeyVaultChallenge" {
  name                        = "mbmKeyVaultChallenge1984"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azurerm_log_analytics_workspace" "mbmLogAnalytics" {
  name                = "mbmLogAnalytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  depends_on = [azurerm_resource_group.mbmRG]
}

resource "azurerm_log_analytics_solution" "mbmLogAnalyticsSolution" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.mbmLogAnalytics.id
  workspace_name        = azurerm_log_analytics_workspace.mbmLogAnalytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


resource "azurerm_public_ip" "mbmPublicIP" {
  name                = "mbmPublicIP"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    environment = "mbm-challenge"
  }
  depends_on = [azurerm_resource_group.mbmRG]
}

module "aks" {
  source                           = "../modules/aks"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  prefix                           = var.prefix
  action_group_id                  = ""
  container_registry_id            = azurerm_container_registry.mbmAzureContainerRegistry.id
  environment                      = "mbm-dev"
  helm_service_principal_object_id = azuread_service_principal.mbmServicePrincipal.id
  key_vault_id                     = azurerm_key_vault.mbmKeyVaultChallenge.id
  log_analytics_workspace_id       = azurerm_log_analytics_workspace.mbmLogAnalytics.id
  outbound_ip_address_ids          = [azurerm_public_ip.mbmPublicIP.id]
  resource_group_network           = data.azurerm_subscription.primary.id
  vm_size                          = "Standard_D2_v2"
  vnet_subnet_id                   = azurerm_subnet.mbmsubnet.id
  color                            = "blue"
  depends_on = [azurerm_resource_group.mbmRG]
}
