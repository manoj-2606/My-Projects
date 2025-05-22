# Multi-Container Application Deployment on Azure Kubernetes Service (AKS)

## Table of Contents
1.  [Project Overview](#1-project-overview)
2.  [Why Azure Kubernetes Service (AKS)?](#2-why-azure-kubernetes-service-aks)
3.  [Project Architecture](#3-project-architecture)
4.  [Prerequisites](#4-prerequisites)
5.  [Step-by-Step Deployment Guide](#5-step-by-step-deployment-guide)
    * [Phase 1: Develop the Multi-Container Application Locally](#phase-1-develop-the-multi-container-application-locally)
    * [Phase 2: Azure Setup (Resource Group, ACR, and Login)](#phase-2-azure-setup-resource-group-acr-and-login)
    * [Phase 3: Build and Push Docker Images](#phase-3-build-and-push-docker-images)
    * [Phase 4: Create Azure Kubernetes Service (AKS) Cluster with Managed Identity](#phase-4-create-azure-kubernetes-service-aks-cluster-with-managed-identity)
    * [Phase 5: Define Kubernetes Manifests (YAML Files)](#phase-5-define-kubernetes-manifests-yaml-files)
    * [Phase 6: Deploy to AKS and Verify](#phase-6-deploy-to-aks-and-verify)
    * [Phase 7: Access Your Deployed Applications](#phase-7-access-your-deployed-applications)
6.  [Troubleshooting: Overcoming "ImagePullBackOff" and "Unauthorized" Errors](#6-troubleshooting-overcoming-imagepullbackoff-and-unauthorized-errors)
    * [The Initial Problem](#the-initial-problem)
    * [The Diagnosis](#the-diagnosis)
    * [The Solution](#the-solution)
7.  [Clean Up Azure Resources](#7-clean-up-azure-resources)

---

## 1. Project Overview

This project demonstrates the end-to-end process of deploying a simple multi-container application to **Azure Kubernetes Service (AKS)**. It involves creating two separate microservices 
(a frontend and a backend API), containerizing them using Docker, storing their images in Azure Container Registry (ACR), and finally orchestrating their deployment and management on a managed Kubernetes 
cluster in Azure.

**Purpose:**
The primary purpose of this project is to understand and implement a robust, scalable, and industry-standard method for deploying cloud-native applications. Moving beyond single-container deployments 
(like on Azure App Service), this project introduces the complexities and advantages of Kubernetes for managing distributed applications.

## 2. Why Azure Kubernetes Service (AKS)?

While simpler services like Azure App Service are excellent for deploying single web applications, real-world applications often involve multiple interconnected services (microservices) that require:

* **Scalability:** Automatically scaling individual components based on demand.
* **Resilience:** Self-healing capabilities that restart failed containers.
* **Service Discovery:** Services finding and communicating with each other easily.
* **Load Balancing:** Distributing incoming traffic across multiple instances of a service.
* **Orchestration:** Managing the lifecycle (deployment, scaling, updates) of hundreds or thousands of containers.

Kubernetes is the de-facto standard for container orchestration, and **AKS** provides a managed Kubernetes experience, significantly reducing the operational overhead of managing the Kubernetes control plane.

## 3. Project Architecture

Our application consists of two distinct services:

* **Frontend Service:**
    * A simple web server (Nginx) serving a static `index.html` file.
    * Accessible publicly via an Azure Load Balancer.
* **Backend Service:**
    * A minimalist Python Flask API that returns a "Hello from Backend" message.
    * Accessible only internally within the Kubernetes cluster (via a `ClusterIP` service). This simulates a backend that might process data or serve APIs for other internal services.

Both services are independently containerized and deployed to the AKS cluster.


+----------------+       +-------------------+       +-----------------------+
|  Your Local PC |       | Azure Container   |       | Azure Kubernetes      |
|                |       | Registry (ACR)    |       | Service (AKS)         |
| +----------+   |       |                   |       |                       |
| | Frontend |   |       | +---------------+ |       |    +--------------+   |
| | (HTML)   |---+-----> | | frontend-app  | |       |    | Frontend Pod |   |
| +----------+   |       | |     image     |<|-------|----|  (Nginx)     |<---|+
|                |       | +---------------+ |       |    +--------------+   |  |
| +----------+   |       |                   |       |                       |  |
| | Backend  |   |       | +---------------+ |       |    +--------------+   |  | Public IP
| | (Flask)  |---+-----> | | backend-app   | |       |    | Backend Pod  |   |  | (Load Balancer)
| +----------+   |       | |     image     |<|-------|----|   (Flask)    |---+
+----------------+       +-------------------+       +-----------------------+
docker push                  AKS pulls images           kubectl apply

## 4. Prerequisites

Ensure you have the following tools installed on your local machine:

* **Docker Desktop:** Essential for building and managing Docker images locally.
    * [Install Docker Desktop](https://docs.docker.com/get-docker/)
* **Azure Account:** A valid Microsoft Azure subscription.
    * [Sign up for a free Azure account](https://azure.microsoft.com/en-in/free/)
* **Azure CLI:** The command-line tool for interacting with Azure resources.
    * [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
    * Verify installation: `az --version`
* **`kubectl`:** The command-line tool for interacting with Kubernetes clusters.
    * Install via Azure CLI: `az aks install-cli`
    * Verify installation: `kubectl version --client`

## 5. Step-by-Step Deployment Guide

### Phase 1: Develop the Multi-Container Application Locally

1.  **Create a New Project Directory:**
    ```bash
    mkdir aks-multi-app
    cd aks-multi-app
    ```

2.  **Create the Frontend Service (`frontend/`):**
    * Create directory: `mkdir frontend && cd frontend`
    * Create `index.html` (paste content below):
      ```html
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>AKS Multi-App Frontend</title>
            <style>
                body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #e0f2f7; color: #007bff; }
                h1 { font-size: 3em; }
                p { font-size: 1.2em; }
            </style>
        </head>
        <body>
            <h1>Hello from the Frontend!</h1>
            <p>This page is served by the Frontend container.</p>
        </body>
        </html>
        ```
       
    * Create `Dockerfile` (paste content below):
        ```dockerfile
        FROM nginx:alpine
        COPY index.html /usr/share/nginx/html/
        EXPOSE 80
        ```
    * Go back to the project root: `cd ..`

3.  **Create the Backend Service (`backend/`):**
    * Create directory: `mkdir backend && cd backend`
    * Create `app.py` (paste Flask code below):
        ```python
        from flask import Flask

        app = Flask(__name__)

        @app.route('/')
        def hello_world():
            return "Hello from the Backend API (v2)!"

        if __name__ == '__main__':
            app.run(host='0.0.0.0', port=5000)
        ```
    * Create `requirements.txt` (paste content below):
        ```
        Flask
        ```
    * Create `Dockerfile` (paste content below):
        ```dockerfile
        FROM python:3.9-slim-buster
        WORKDIR /app
        COPY requirements.txt .
        RUN pip install -r requirements.txt
        COPY . .
        EXPOSE 5000
        CMD ["python", "app.py"]
        ```
    * Go back to the project root: `cd ..`

### Phase 2: Azure Setup (Resource Group, ACR, and Login)

1.  **Log in to Azure CLI:**
    ```bash
    az login
    ```
    Follow the browser instructions to complete authentication.

2.  **Set Your Azure Subscription (if you have multiple):**
    ```bash
    az account set --subscription "<Your Azure Subscription Name or ID>"
    ```

3.  **Create a Resource Group:**
    This resource group will host both your ACR and AKS cluster.
    ```bash
    az group create --name aks-dev-rg --location centralindia
    ```
    *(Adjust `centralindia` to your preferred Azure region).*

4.  **Create Azure Container Registry (ACR):**
    ```bash
    az acr create --resource-group aks-dev-rg --name aksdevacr007 --sku Basic --admin-enabled true
    ```
    * **Important:** Replace `aksdevacr007` with a **globally unique name** for your ACR.
    * `--admin-enabled true`: Enables an admin user for initial Docker CLI login.

5.  **Get Your ACR Login Server Name:**
    ```bash
    az acr show --name aksdevacr007 --query loginServer --output tsv
    ```
    Copy the output (e.g., `aksdevacr007.azurecr.io`). This is your `<your-acr-login-server>`.

6.  **Log in to ACR from Docker CLI:**
    You'll need the ACR username and password from the Azure portal (navigate to your ACR -> "Access keys").
    ```bash
    docker login <your-acr-login-server> -u <your-acr-username> -p <your-acr-password>
    ```

### Phase 3: Build and Push Docker Images

1.  **Build and Push Frontend Image:**
    * Change directory: `cd frontend`
    * Build:
        ```bash
        docker build -t <your-acr-login-server>/aks-frontend:latest .
        ```
    * Push:
        ```bash
        docker push <your-acr-login-server>/aks-frontend:latest
        ```
    * Go back to project root: `cd ..`

2.  **Build and Push Backend Image:**
    * Change directory: `cd backend`
    * Build:
        ```bash
        docker build -t <your-acr-login-server>/aks-backend:latest .
        ```
    * Push:
        ```bash
        docker push <your-acr-login-server>/aks-backend:latest
        ```
    * Go back to project root: `cd ..`

    **Verify Image Existence in ACR:** After pushing, navigate to your ACR in the Azure Portal -> "Repositories". Confirm that `aks-frontend` and `aks-backend` repositories exist, each with a `latest` tag.
    This is crucial for avoiding "Image Not Found" errors later.

### Phase 4: Create Azure Kubernetes Service (AKS) Cluster with Managed Identity

This step correctly sets up permissions for AKS to pull images from your ACR using Azure's secure Managed Identity feature.

1.  **Create AKS Cluster:**
    This command creates a basic AKS cluster with 1 node and **automatically grants it `AcrPull` permissions** on your specified ACR. This is the **most reliable way** to handle ACR integration.
    ```bash
    az aks create \
        --resource-group aks-dev-rg \
        --name myakscluster \
        --node-count 1 \
        --generate-ssh-keys \
        --enable-managed-identity \
        --attach-acr aksdevacr007
    ```
    * `--name myakscluster`: Choose a unique name for your AKS cluster.
    * `--enable-managed-identity`: Activates a system-assigned managed identity for the AKS cluster.
    * `--attach-acr aksdevacr007`: Grants the AKS cluster's managed identity the `AcrPull` role on `aksdevacr007`.

    *(This command can take 5-15 minutes to complete.)*

2.  **Get AKS Cluster Credentials:**
    Configure `kubectl` to connect to your new AKS cluster:
    ```bash
    az aks get-credentials --resource-group aks-dev-rg --name myakscluster --overwrite-existing
    ```

3.  **Verify `kubectl` Connection:**
    ```bash
    kubectl get nodes
    ```
    You should see your AKS node listed with a "Ready" status.

### Phase 5: Define Kubernetes Manifests (YAML Files)

These YAML files instruct Kubernetes on how to deploy and expose your applications. Create these in your `aks-multi-app` root directory.

1.  **`frontend-deployment.yaml`:**
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend-deployment
      labels:
        app: frontend
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: frontend
      template:
        metadata:
          labels:
            app: frontend
        spec:
          containers:
          - name: frontend
            image: <your-acr-login-server>/aks-frontend:latest # REPLACE WITH YOUR ACR LOGIN SERVER (e.g., aksdevacr007.azurecr.io)
            ports:
            - containerPort: 80
          imagePullPolicy: Always # Always pull the latest image during development
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: frontend-service
    spec:
      selector:
        app: frontend
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
      type: LoadBalancer # Exposes the service to the internet
    ```
    **Remember to replace `<your-acr-login-server>`** with your actual ACR login server name (e.g., `aksdevacr007.azurecr.io`).

2.  **`backend-deployment.yaml`:**
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: backend-deployment
      labels:
        app: backend
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: backend
      template:
        metadata:
          labels:
            app: backend
        spec:
          containers:
          - name: backend
            image: <your-acr-login-server>/aks-backend:latest # REPLACE WITH YOUR ACR LOGIN SERVER (e.g., aksdevacr007.azurecr.io)
            ports:
            - containerPort: 5000
          imagePullPolicy: Always # Always pull the latest image during development
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: backend-service
    spec:
      selector:
        app: backend
      ports:
        - protocol: TCP
          port: 5000
          targetPort: 5000
      type: ClusterIP # Internal service, not directly exposed to internet
    ```
    **Remember to replace `<your-acr-login-server>`** with your actual ACR login server name (e.g., `aksdevacr007.azurecr.io`).

### Phase 6: Deploy to AKS and Verify

1.  **Deploy the Frontend:**
    ```bash
    kubectl apply -f frontend-deployment.yaml
    ```

2.  **Deploy the Backend:**
    ```bash
    kubectl apply -f backend-deployment.yaml
    ```

3.  **Monitor Deployments and Pods:**
    ```bash
    kubectl get deployments
    kubectl get pods
    ```
    Wait until both deployments show `1/1` READY, and all pods show `Running` status.

4.  **Monitor Services and Get External IP:**
    ```bash
    kubectl get services
    ```
    For `frontend-service`, wait until `EXTERNAL-IP` changes from `<pending>` to an actual public IP address. This might take a few minutes.
    ```bash
    kubectl get service frontend-service --watch
    ```

### Phase 7: Access Your Deployed Applications

1.  **Access Frontend:**
    Once the `frontend-service` has an `EXTERNAL-IP`, copy that IP address and paste it into your web browser. You should see:
    ```
    Hello from the Frontend!
    This page is served by the Frontend container.
    ```

2.  **Access Backend (Internal Access for now):**
    The `backend-service` is of `ClusterIP` type, meaning it's only accessible from within the Kubernetes cluster. To verify it's running for development/debugging, you can use `kubectl port-forward`:
    ```bash
    kubectl port-forward service/backend-service 8080:5000
    ```
    Then, open `http://localhost:8080` in your browser. You should see:
    ```
    Hello from the Backend API (v2)!
    ```
    Press `Ctrl+C` in your terminal to stop the port-forwarding.

## 6. Troubleshooting: Overcoming "ImagePullBackOff" and "Unauthorized" Errors

This project faced a common and frustrating issue during deployment: the AKS cluster failed to pull images from ACR, resulting in `ImagePullBackOff` and `ErrImagePull` statuses for the pods.

### The Initial Problem

When running `kubectl get pods`, the backend pod consistently showed statuses like `ErrImagePull` or `ImagePullBackOff`.
A `kubectl describe pod <pod-name>` revealed the core issues in the Events section:
* `Failed to pull image ...: aksdevacr007.azurecr.io/aks-backend:latest: not found`
* `Failed to authorize: ... 401 Unauthorized`

### The Diagnosis

This dual error pointed to two potential problems:

1.  **Image Not Found:** The image `aks-backend:latest` was genuinely missing from the specified Azure Container Registry. This was the primary reason for the "not found" message.
2.  **Authorization Failure:** Even if the image existed, the AKS cluster's identity might not have had the necessary permissions (`AcrPull` role) to access images in the ACR. The "401 Unauthorized" suggested this.

### The Solution

The resolution involved a meticulous two-pronged approach:

1.  **Verifying and Correcting Image Presence in ACR:**
    * **Action:** Navigated to Azure Portal -> ACR -> Repositories.
    * **Discovery:** Confirmed that `aks-backend` repository (or the `latest` tag within it) was indeed missing. This indicated that the `docker push` command in Phase 3 for the backend image
    * had either failed or was executed with an incorrect image name/tag.
    * **Remedy:** Re-executed the `docker build` and `docker push` commands for the backend image (Phase 3, Step 2), ensuring the correct ACR login server and image name (`aks-backend:latest`) were used.
    * Close attention was paid to the command line output for any errors during the build and push process. After successful push, verification in Azure Portal confirmed the image's presence.

2.  **Explicitly Granting `AcrPull` Role to AKS Managed Identity (Robust Authorization):**
    * **Action:** Even though `--attach-acr` is designed to handle this, it's crucial to ensure the `AcrPull` role was explicitly assigned.
    * **Commands used:**
        ```bash
        # Get ACR Resource ID
        ACR_RESOURCE_ID=$(az acr show --name aksdevacr007 --query id --output tsv)

        # Get AKS Managed Identity Principal ID
        AKS_PRINCIPAL_ID=$(az aks show --resource-group aks-dev-rg --name myakscluster --query identity.principalId --output tsv)

        # Assign AcrPull Role
        az role assignment create \
            --assignee $AKS_PRINCIPAL_ID \
            --role "AcrPull" \
            --scope $ACR_RESOURCE_ID
        ```
    * This command ensures the AKS cluster's managed identity has the necessary permissions to pull images from your specific ACR.

After rectifying the `docker push` issue (ensuring the image was present) and confirming the `AcrPull` role assignment, deleting the old failing pods and re-applying the backend deployment 
(`kubectl apply -f backend-deployment.yaml`) successfully brought the backend service online.

## 7. Clean Up Azure Resources

To avoid unnecessary costs, always clean up your Azure resources when you are finished.

1.  **Delete Kubernetes Deployments and Services:**
    ```bash
    kubectl delete -f frontend-deployment.yaml
    kubectl delete -f backend-deployment.yaml
    ```

2.  **Delete the Entire Resource Group:**
    This command will delete the AKS cluster, its associated nodes, your ACR, and all other resources within the `aks-dev-rg` resource group.
    ```bash
    az group delete --name aks-dev-rg --yes --no-wait
    ```

## Frontend Output Image

![Frontend Output Image]([https://github.com/manoj-2606/My-Projects/blob/ca616ad1260011d468b7fbdb453bc3d334a312d1/Project6/Output%20Image.png](https://github.com/manoj-2606/My-Projects/blob/fa9cc0ecd3a20c39a54b4c114136f5405e5af9c5/Project7/Frontend-api-Output.png))

---

## Backend Output Image

![Backend Output Image]([https://github.com/manoj-2606/My-Projects/blob/ca616ad1260011d468b7fbdb453bc3d334a312d1/Project6/Output%20Image.png](https://github.com/manoj-2606/My-Projects/blob/fa9cc0ecd3a20c39a54b4c114136f5405e5af9c5/Project7/Backend-api-output.png))

---

---
