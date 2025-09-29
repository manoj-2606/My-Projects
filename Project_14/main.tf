 main.tf

# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Azure Provider to use Azure CLI authentication
provider "azurerm" {
  features {}
  subscription_id = "4985f681-bfb3-4e92-a131-b1e85dd4f934"
}

# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = "project-learn"
  location = "Central India"  # Fixed: removed trailing space
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "main" {
  name                = "acrprojectlearn2024"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# Create an Azure Kubernetes Service (AKS) cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-project-learn"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aksprojectlearn"
  # REMOVED: kubernetes_version - Let Azure choose the latest stable version

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }
}
#Grant AKS cluster pull access to ACR (Using the main cluster identity)
#resource "azurerm_role_assignment" "aks_acr" {
#principal_id                     = azurerm_kubernetes_cluster.main.identity[0].principal_id
#role_definition_name             = "AcrPull"
#scope                            = azurerm_container_registry.main.id
#skip_service_principal_aad_check = true
#}
