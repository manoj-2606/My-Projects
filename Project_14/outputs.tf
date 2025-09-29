# outputs.tf - Useful output values

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "acr_login_server" {
  description = "The login server URL for ACR"
  value       = azurerm_container_registry.main.login_server
}

output "kube_config" {
  description = "Kubernetes config to access the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}
