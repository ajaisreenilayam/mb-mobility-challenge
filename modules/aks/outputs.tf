output "name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "(to be deprecated in favour of `azurerm_kubernetes_cluster` and will be removed in v3) Kubernetes cluster name"
}

output "azurerm_kubernetes_cluster" {
  value       = azurerm_kubernetes_cluster.aks
  description = "Kubernetes cluster object"
}
