---
# Project: Azure Core Foundation - Secure Web Infrastructure
This project demonstrates the deployment of a complete, secure Azure infrastructure using Infrastructure as Code (Bicep). It includes networking, compute, storage, and monitoring components to host a web application with an image served from Azure Blob Storage.

# Project Goal
To build hands-on experience with core Azure services by deploying a foundational, secure network infrastructure with a web application, implementing proper security controls, monitoring, and storage integration.

# Architecture & Components
The solution utilizes the following Azure resources:

Resource Group: (Project1-RG) - A logical container for all project-related Azure resources.

Virtual Network (VNet): (webapp{uniqueString}-vnet) - Provides network isolation with a dedicated subnet.

Network Security Group (NSG): (webapp{uniqueString}-nsg) - Controls inbound/outbound traffic with specific security rules.

Linux Virtual Machine (VM): (webapp{uniqueString}-vm) - Ubuntu server running Nginx web server.

Blob Storage Account: (sa{uniqueString}) - Storage account hosting static images for the web application.

Azure Monitor: - Performance monitoring and alerting system for the VM.

Action Group: - Configuration for email notifications from alerts.

text
Internet Traffic
      ↓
+-----------------------------+
| Network Security Group      |
| - Allow HTTP (80)           |
| - Allow HTTPS (443)         |
| - Allow SSH (22)            |
| - Deny All Other Inbound    |
+-----------------------------+
      ↓
+-----------------------------+
| Virtual Network & Subnet    |
+-----------------------------+
      ↓
+-----------------------------+
| Linux VM (Ubuntu + Nginx)   | ←→ Azure Monitor (CPU Alerts)
+-----------------------------+
      ↓
+-----------------------------+
| Blob Storage Container      |
| - Public image hosting      |
+-----------------------------+

# Learning Objectives
Upon completing this project, you will understand:

How to deploy Azure infrastructure using Bicep (Infrastructure as Code)

Virtual Network and subnet configuration for network isolation

Network Security Group rules for controlling traffic flow

Linux VM deployment and web server installation (Nginx)

Blob Storage configuration for public content hosting

Azure Monitor setup for performance metrics collection

Alert rules configuration for proactive monitoring

RBAC permissions management for storage operations

Troubleshooting common deployment and configuration issues

# Prerequisites
An active Azure subscription

Azure CLI installed

Bicep CLI installed

Basic knowledge of Linux command line

Project Steps: Complete Walkthrough
Phase 1: Environment Setup
Install and Configure Tools:

bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Bicep
az bicep install

# Login to Azure
az login
Create Project Directory:

bash
mkdir azure-project
cd azure-project
Phase 2: Bicep Template Deployment
Create Bicep Template Files:

main.bicep - Main infrastructure template

parameters.json - Deployment parameters

install-webserver.sh - VM bootstrap script

Deploy Infrastructure:

bash
# Create resource group
az group create --name Project1-RG --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group Project1-RG \
  --template-file main.bicep \
  --parameters @parameters.json
Phase 3: Storage Configuration
Upload Image to Blob Storage:

bash
# Get storage account key
storage_key=$(az storage account keys list \
  --account-name <storage-account-name> \
  --resource-group Project1-RG \
  --query '[0].value' \
  -o tsv)

# Upload image
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name images \
  --name sample-image.jpg \
  --file sample-image.jpg \
  --account-key $storage_key

# Set container to public access
az storage container set-permission \
  --account-name <storage-account-name> \
  --name images \
  --public-access blob \
  --account-key $storage_key
Phase 4: Web Server Configuration
SSH into VM and Configure Web Server:

bash
# SSH into VM (use password from parameters.json)
ssh azureuser@<vm-public-ip>

# Update HTML with blob URL
blob_url="https://<storage-account-name>.blob.core.windows.net/images/sample-image.jpg"
sudo sed -i "s|REPLACE_WITH_BLOB_URL|$blob_url|g" /var/www/html/index.html

# Restart Nginx
sudo systemctl restart nginx

# Exit SSH
exit
Phase 5: Monitoring Configuration
Verify Monitoring Setup:

bash
# Check diagnostic settings
az monitor diagnostic-settings list \
  --resource $(az vm show --name <vm-name> --resource-group Project1-RG --query id --output tsv)

# Check alert rules
az monitor metrics alert list --resource-group Project1-RG

# Check action groups
az monitor action-group list --resource-group Project1-RG
Phase 6: Testing and Validation
Test Web Application:

bash
# Test web server
curl http://<vm-public-ip>

# Test blob access
curl -I https://<storage-account-name>.blob.core.windows.net/images/sample-image.jpg
Test Monitoring Alerts (Optional):

bash
# SSH into VM and generate CPU load
ssh azureuser@<vm-public-ip>
sudo apt-get install stress-ng -y
stress-ng --cpu 4 --timeout 300s
Challenges Faced & Solutions
1. Storage Account Public Access Configuration
Issue: Azure's default security settings block public access to storage accounts
Solution: Added allowBlobPublicAccess: true property to storage account configuration in Bicep template

2. RBAC Permissions for Blob Upload
Issue: "Storage Blob Data Contributor" role required for upload operations
Solution: Used storage account key authentication instead of RBAC for simplicity

3. Alert Configuration Syntax
Issue: Complex criteria syntax with specific odata.type requirements
Solution: Used correct criterion types and proper object structure in Bicep template

4. Bicep Validation Warnings
Issue: Template validation warnings about hardcoded URLs
Solution: Used environment().suffixes.storage function for cloud compatibility

5. Custom Script Execution
Issue: Ensuring custom script runs properly during VM provisioning
Solution: Used customData property with base64-encoded script content

Key Learnings
Infrastructure as Code
Bicep template structure and syntax

Parameter management and secure strings

Resource dependencies and deployment sequencing

Output values for cross-resource referencing

Azure Networking
VNet and subnet configuration

NSG rule prioritization and management

Public IP address allocation

Network interface configuration

Security Best Practices
Principle of least privilege for NSG rules

Secure password handling in parameters

Storage account security configurations

Monitoring and alerting for security events

Monitoring & Operations
Azure Monitor diagnostic settings

Metric alert configuration

Action groups for notifications

Performance metric collection

Cleanup
To avoid ongoing charges, delete the resource group which will remove all associated resources:

bash
az group delete --name Project1-RG --yes --no-wait

---
