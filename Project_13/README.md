# Project: Azure Core Foundation - Secure Web Infrastructure

This project demonstrates the deployment of a complete, secure Azure infrastructure using Infrastructure as Code (Bicep). It includes networking, compute, storage, and monitoring components to host a web application with an image served from Azure Blob Storage.

## Project Goal

To build hands-on experience with core Azure services by deploying a foundational, secure network infrastructure with a web application, implementing proper security controls, monitoring, and storage integration.

## Architecture & Components

The solution utilizes the following Azure resources:

- **Resource Group:** (`Project1-RG`) - Logical container for project resources.
- **Virtual Network (VNet):** (`webapp{uniqueString}-vnet`) - Provides network isolation with a dedicated subnet.
- **Network Security Group (NSG):** (`webapp{uniqueString}-nsg`) - Controls traffic flow, allowing HTTP (80), HTTPS (443), and SSH (22).
- **Linux Virtual Machine (VM):** (`webapp{uniqueString}-vm`) - Ubuntu server running Nginx web server.
- **Blob Storage Account:** (`sa{uniqueString}`) - Stores static images for the web app.
- **Azure Monitor:** Monitors VM performance and triggers alerts.
- **Action Group:** Sends email notifications for alerts.

Internet Traffic
↓
+-----------------------------+
| Network Security Group |
| - Allow HTTP (80) |
| - Allow HTTPS (443) |
| - Allow SSH (22) |
| - Deny All Other Inbound |
+-----------------------------+
↓
+-----------------------------+
| Virtual Network & Subnet |
+-----------------------------+
↓
+-----------------------------+
| Linux VM (Ubuntu + Nginx) | ←→ Azure Monitor (CPU Alerts)
+-----------------------------+
↓
+-----------------------------+
| Blob Storage Container |
| - Public image hosting |
+-----------------------------+


## Learning Objectives

- Deploy Azure infrastructure using Bicep (Infrastructure as Code)
- Configure VNet and subnet for network isolation
- Manage NSG rules for traffic control
- Deploy Linux VM with web server (Nginx)
- Configure Blob Storage for public content hosting
- Enable Azure Monitor for performance metrics and alerts
- Implement RBAC for storage access
- Troubleshoot common deployment/configuration issues

## Prerequisites

- Active Azure subscription
- Azure CLI installed
- Bicep CLI installed
- Basic Linux command-line knowledge

## Project Steps: A Complete Walkthrough

### Phase 1: Environment Setup

1. Install Tools:
    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    az bicep install
    az login
    ```

2. Create Project Directory:
    ```bash
    mkdir azure-project
    cd azure-project
    ```

### Phase 2: Deploy Infrastructure

1. Create Bicep Templates:
    - `main.bicep`
    - `parameters.json`
    - `install-webserver.sh`

2. Create Resource Group:
    ```bash
    az group create --name Project1-RG --location eastus
    ```

3. Deploy Infrastructure:
    ```bash
    az deployment group create \
      --resource-group Project1-RG \
      --template-file main.bicep \
      --parameters @parameters.json
    ```

### Phase 3: Configure Storage

1. Upload Image to Blob Storage:
    ```bash
    storage_key=$(az storage account keys list \
      --account-name <storage-account-name> \
      --resource-group Project1-RG \
      --query '[0].value' -o tsv)

    az storage blob upload \
      --account-name <storage-account-name> \
      --container-name images \
      --name sample-image.jpg \
      --file sample-image.jpg \
      --account-key $storage_key

    az storage container set-permission \
      --account-name <storage-account-name> \
      --name images \
      --public-access blob \
      --account-key $storage_key
    ```

### Phase 4: Configure Web Server

1. SSH into VM:
    ```bash
    ssh azureuser@<vm-public-ip>
    ```

2. Update HTML Page with Blob URL:
    ```bash
    blob_url="https://<storage-account-name>.blob.core.windows.net/images/sample-image.jpg"
    sudo sed -i "s|REPLACE_WITH_BLOB_URL|$blob_url|g" /var/www/html/index.html
    sudo systemctl restart nginx
    exit
    ```

### Phase 5: Monitoring Setup

1. Verify Monitoring:
    ```bash
    az monitor diagnostic-settings list \
      --resource $(az vm show --name <vm-name> --resource-group Project1-RG --query id --output tsv)

    az monitor metrics alert list --resource-group Project1-RG
    az monitor action-group list --resource-group Project1-RG
    ```

### Phase 6: Testing and Validation

1. Test Web Application:
    ```bash
    curl http://<vm-public-ip>
    curl -I https://<storage-account-name>.blob.core.windows.net/images/sample-image.jpg
    ```

2. (Optional) Simulate CPU Load:
    ```bash
    ssh azureuser@<vm-public-ip>
    sudo apt-get install stress-ng -y
    stress-ng --cpu 4 --timeout 300s
    ```

## Challenges & Solutions

- Storage public access: Used `allowBlobPublicAccess: true` in Bicep.
- RBAC permissions: Used storage account key for simplicity.
- Alert config syntax: Corrected criterion types in Bicep.
- Validation warnings: Used `environment().suffixes.storage`.
- Custom script execution: Used base64-encoded `customData`.

## Key Learnings

- Infrastructure as Code best practices
- Secure network and storage setup
- Monitoring & proactive alerting
- Debugging and validation techniques

## Cleanup

```bash
az group delete --name Project1-RG --yes --no-wait
