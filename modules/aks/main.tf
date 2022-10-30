# ------------------
# Client Config
# ------------------
data "azurerm_client_config" "current" {
}

locals {
  env_name = "${var.prefix}-${var.location}-${var.environment}%{if var.color != ""}-${var.color}%{endif}"
}

# ------------------
# AKS
# ------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                            = "aks-${local.env_name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = "aks-${local.env_name}"
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    vm_size             = var.vm_size
    os_disk_size_gb     = var.node_disk_size_gb
    #availability_zones  = var.availability_zones # This is not part of default_node_pool Link: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#default_node_pool
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    vnet_subnet_id      = var.vnet_subnet_id
    node_labels         = {}
    node_taints         = []
    tags                = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

#  role_based_access_control {
#    enabled = true
#    azure_active_directory {
#      azure_rbac_enabled     = true
#      managed                = true
#      admin_group_object_ids = var.admin_group_object_ids
#    }
#  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    load_balancer_profile {
      outbound_ip_address_ids = var.outbound_ip_address_ids
    }
  }

#  addon_profile { ## Addon profile is not available argument under this
#    azure_policy {
#      enabled = true
#    }
#  }
  oms_agent {
      #enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
  }


  tags = var.tags
}

# ------------------
# Role Assignments
# ------------------

# Assign Helm service principle
resource "azurerm_role_assignment" "helm_service_principle" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.helm_service_principal_object_id
}

# Assign ACR pull right to managed itdentity from AKS
resource "azurerm_key_vault_access_policy" "csi_access_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id

  certificate_permissions = [
    "Get"
  ]

  key_permissions = [
    "Get"
  ]

  secret_permissions = [
    "Get"
  ]
}

# ------------------
# Role Assignments
# ------------------

# Assign ACR pull right to managed itdentity from AKS
resource "azurerm_role_assignment" "acrpull_role" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "network_contributor_role_aks_rg" {
  scope                = var.resource_group_network
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

# Needed for 'Microsoft.Network/publicIPAddresses/read'
resource "azurerm_role_assignment" "virtual_machine_administrator_login_role_aks_rg" {
  scope                = var.resource_group_network
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

# ------------------
# Diagnostic Settings
# ------------------
resource "azurerm_monitor_diagnostic_setting" "aks_diagnostics" {
  name               = "diagnostic-aks-${local.env_name}"
  target_resource_id = azurerm_kubernetes_cluster.aks.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "guard"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}

data "azurerm_lb" "aks_lb" {
  name                = "kubernetes"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_monitor_diagnostic_setting" "aks_lb_diagnostics" {
  name               = "diagnostic-aks-lb-${local.env_name}"
  target_resource_id = data.azurerm_lb.aks_lb.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "LoadBalancerAlertEvent"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  log {
    category = "LoadBalancerProbeHealthStatus"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}