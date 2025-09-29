# 🚀 AKS & ACR Infrastructure as Code with Terraform

![Azure](https://img.shields.io/badge/Azure-Cloud--Native-blue)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Container%20Orchestration-blue)
![ACR](https://img.shields.io/badge/ACR-Container%20Registry-orange)

---

## 📖 Introduction

This project demonstrates **Infrastructure as Code (IaC)** by building an Azure Kubernetes Service (AKS) cluster and Azure Container Registry (ACR) using Terraform. It represents the absolute foundation for modern cloud-native applications and DevOps practices.

**Why This Project?**
- Learn to treat cloud infrastructure as software code
- Master fundamental DevOps skills and workflows
- Gain hands-on experience with real-world troubleshooting
- Build repeatable, version-controlled environments
- Establish the foundation for CI/CD pipelines

---

## 🏗️ Architecture Overview

```
┌─────────────────┐           ┌──────────────────┐
│    Azure ACR    │◄──────────│    Azure AKS     │
│ (Container      │           │ (Kubernetes      │
│  Registry)      │           │  Cluster)        │
│                 │           │                  │
│ - Store Docker  │           │ - Run containers │
│   images        │           │ - Auto-scale     │
│ - Secure repo   │           │ - Managed service│
└─────────────────┘           └──────────────────┘
```

**Infrastructure Flow:**  
Terraform Code → Azure Resource Group → ACR + AKS → Secure Integration

---

## 📋 Requirements

### Prerequisites

- **Azure Account** with active subscription
- **Azure CLI** installed on your machine
- **Terraform** installed
- **Docker** installed (for integration testing)
- Basic knowledge of command line operations

### Azure Permissions

- Contributor or Owner role on the subscription
- Permission to create resource groups, AKS clusters, and ACR registries

---

## 🛠️ Implementation Guide

### Step 1: Environment Setup

```bash
# Verify installations
terraform -version
az --version
docker --version

# Authenticate with Azure
az login
az account set --subscription="YOUR_SUBSCRIPTION_ID"
```

---

### Step 2: Project Structure

```bash
# Create project directory
mkdir terraform-aks-project
cd terraform-aks-project
```

---

### Step 3: Terraform Configuration

Create a file called `main.tf` with the following content:

```hcl
# main.tf - AKS & ACR Infrastructure

# Configure Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "YOUR_SUBSCRIPTION_ID"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-aks-project-learn"
  location = "Central India"
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acrprojectlearn2024" # Must be unique globally
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-project-learn"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aksprojectlearn"

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
```

---

### Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration (type 'yes' when prompted)
terraform apply
```

---

### Step 5: AKS-ACR Integration

```bash
# Secure integration between AKS and ACR
az aks update --resource-group rg-aks-project-learn --name aks-project-learn --attach-acr acrprojectlearn2024
```

---

### Step 6: End-to-End Testing

```bash
# Create test deployment file
cat > test-acr-pull.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-acr-pull
spec:
  containers:
  - name: test-container
    image: acrprojectlearn2024.azurecr.io/hello-world:latest
  imagePullSecrets: []
EOF

# Push test image to ACR
az acr update --name acrprojectlearn2024 --admin-enabled true
docker pull hello-world
docker tag hello-world acrprojectlearn2024.azurecr.io/hello-world:latest
docker login acrprojectlearn2024.azurecr.io --username acrprojectlearn2024 --password $(az acr credential show --name acrprojectlearn2024 --query passwords[0].value -o tsv)
docker push acrprojectlearn2024.azurecr.io/hello-world:latest

# Deploy and verify
az aks get-credentials --resource-group rg-aks-project-learn --name aks-project-learn --overwrite-existing
kubectl apply -f test-acr-pull.yaml
kubectl logs test-acr-pull
```

#### ✅ Expected Output: Successful Deployment Verification

```bash
# Verify AKS cluster
az aks list --resource-group rg-aks-project-learn --output table
# Output: Shows AKS cluster with 'Succeeded' status

# Verify ACR registry
az acr list --resource-group rg-aks-project-learn --output table
# Output: Shows ACR registry details

# Verify Kubernetes nodes
kubectl get nodes
# Output: Shows node with 'Ready' status

# Verify application deployment
kubectl logs test-acr-pull
# Output: "Hello from Docker!" message
```

**Sample Success Output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## 🗑️ Resource Cleanup

**Option 1: Terraform Destroy (Recommended)**
```bash
# Destroy all created resources
terraform destroy
# Type 'yes' when prompted
```

**Option 2: Manual Cleanup**
```bash
# Delete resource group (includes all resources)
az group delete --name rg-aks-project-learn --yes --no-wait

# Verify deletion
az group exists --name rg-aks-project-learn
# Output: false
```

---

## 🔧 Troubleshooting Common Issues

### Authentication Issues

**Problem:** subscription ID could not be determined  
**Solution:**
```bash
az login
az account set --subscription="YOUR_SUBSCRIPTION_ID"
```

### Version Compatibility

**Problem:** K8sVersionNotSupported  
**Solution:** Remove explicit `kubernetes_version` from configuration.

### AKS-ACR Integration

**Problem:** 401 Unauthorized when pulling images  
**Solution:**
```bash
az aks update --resource-group rg-aks-project-learn --name aks-project-learn --attach-acr acrprojectlearn2024
```

### Resource Naming

**Problem:** Resource name not unique  
**Solution:** Use unique names across Azure (add initials/timestamp).

---
