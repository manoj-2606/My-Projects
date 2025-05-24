# Project 8: Automated Multi-Container Application Deployment on Azure Kubernetes Service (AKS) with GitHub Actions CI/CD

## Table of Contents
1.  [Project Overview](#1-project-overview)
2.  [Why Azure Kubernetes Service (AKS)?](#2-why-azure-kubernetes-service-aks)
3.  [Why GitHub Actions for CI/CD?](#3-why-github-actions-for-cicd)
4.  [Project Architecture](#4-project-architecture)
5.  [Prerequisites](#5-prerequisites)
6.  [Step-by-Step Deployment Guide](#6-step-by-step-deployment-guide)
    * [Phase 0: Re-create the Project Structure Locally](#phase-0-re-create-the-project-structure-locally)
    * [Phase 1: Azure Setup (Resource Group, ACR, and Docker Login)](#phase-1-azure-setup-resource-group-acr-and-docker-login)
    * [Phase 2: Create Azure Service Principal (for GitHub Actions Authentication)](#phase-2-create-azure-service-principal-for-github-actions-authentication)
    * [Phase 3: Add Service Principal Credentials to GitHub Secrets](#phase-3-add-service-principal-credentials-to-github-secrets)
    * [Phase 4: Create Kubernetes Manifests (YAML Files) for Project 8](#phase-4-create-kubernetes-manifests-yaml-files-for-project-8)
    * [Phase 5: Commit Initial Project Files to GitHub](#phase-5-commit-initial-project-files-to-github)
    * [Phase 6: Create the GitHub Actions Workflow File for Project 8](#phase-6-create-the-github-actions-workflow-file-for-project-8)
    * [Phase 7: Create AKS Cluster with Managed Identity](#phase-7-create-aks-cluster-with-managed-identity)
    * [Phase 8: Trigger the CI/CD Pipeline](#phase-8-trigger-the-cicd-pipeline)
7.  [Troubleshooting Journey: Overcoming Challenges](#7-troubleshooting-journey-overcoming-challenges)
    * [Challenge 1: GitHub Push Authentication (Password Deprecation)](#challenge-1-github-push-authentication-password-deprecation)
    * [Challenge 2: GitHub Actions Workflow Not Triggering](#challenge-2-github-actions-workflow-not-triggering)
    * [Challenge 3: AKS ImagePullBackOff / Unauthorized / Image Not Found](#challenge-3-aks-imagepullbackoff--unauthorized--image-not-found)
    * [Challenge 4: Kubernetes YAML Indentation Error (`imagePullPolicy`)](#challenge-4-kubernetes-yaml-indentation-error-imagepullpolicy)
8.  [Final Output & Verification](#8-final-output--verification)
9.  [Clean Up Azure Resources](#9-clean-up-azure-resources)

---

## 1. Project Overview

This project marks a significant milestone in cloud-native application deployment. It demonstrates how to establish a 
fully automated Continuous Integration/Continuous Delivery (CI/CD) pipeline using **GitHub Actions** to deploy a multi-container 
application to **Azure Kubernetes Service (AKS)**.

The application consists of a simple **Frontend** (Nginx serving static HTML) and a **Backend API** (Python Flask). These 
services are containerized using Docker, stored in **Azure Container Registry (ACR)**, and orchestrated by AKS.

**Purpose of this Project:**
The core purpose is to move beyond manual deployments and embrace automation. In real-world scenarios, manual steps are prone to errors, 
time-consuming, and hinder rapid iteration. By automating the entire build, push, and deploy process, we achieve:

* **Speed:** Faster delivery of new features and bug fixes.
* **Reliability:** Consistent deployments, reducing human error.
* **Efficiency:** Freeing up development and operations teams to focus on more complex tasks.
* **Scalability:** The pipeline can handle increasing complexity and frequency of deployments.
* **Visibility:** Clear logs and status updates for every deployment.

## 2. Why Azure Kubernetes Service (AKS)?

While simpler services like Azure App Service are suitable for single-container web applications, they become less efficient for complex, 
distributed systems. AKS provides:

* **Container Orchestration:** Manages the lifecycle of multiple containers across a cluster of virtual machines.
* **Scalability:** Automatically scales application instances up or down based on demand.
* **High Availability:** Distributes applications across multiple nodes, ensuring resilience to failures.
* **Service Discovery:** Enables seamless communication between different microservices within the cluster.
* **Resource Management:** Efficiently allocates compute, memory, and storage resources to containers.
* **Managed Service:** Azure handles the underlying Kubernetes control plane, reducing operational burden.

This project demonstrates how AKS enables us to run and manage our separate frontend and backend services as a cohesive application.

## 3. Why GitHub Actions for CI/CD?

In previous projects, we manually executed `docker build`, `docker push`, and `kubectl apply` commands. While effective for learning, 
this is not sustainable for production. GitHub Actions provides:

* **Automation:** Automatically triggers workflows based on Git events (e.g., pushes to `main`).
* **Integration with GitHub:** Seamlessly integrates with your source code repository, keeping everything in one place.
* **Infrastructure as Code for CI/CD:** Workflows are defined in YAML files, allowing them to be version-controlled, reviewed, and
* managed like any other code.
* **Extensibility:** A vast marketplace of pre-built actions for common tasks (Azure login, AKS context, Docker build/push).
* **Traceability:** Provides detailed logs for every step of the pipeline, making debugging easier.

By using GitHub Actions, we transform our manual deployment process into an automated, repeatable, and reliable pipeline.

## 4. Project Architecture

The application is composed of two distinct, containerized services:

* **Frontend Service:** A static web page served by an Nginx container.
    * **Dockerfile:** `Project8/frontend/Dockerfile`
    * **Source:** `Project8/frontend/index.html`
    * **Kubernetes Manifest:** `Project8/frontend-deployment.yaml` (uses `type: LoadBalancer` for public access)
* **Backend Service:** A simple Flask API that returns a string message.
    * **Dockerfile:** `Project8/backend/Dockerfile`
    * **Source:** `Project8/backend/app.py`, `Project8/backend/requirements.txt`
    * **Kubernetes Manifest:** `Project8/backend-deployment.yaml` (uses `type: ClusterIP` for internal access)

The CI/CD pipeline automates:
1.  Building Docker images for both services.
2.  Pushing these images to Azure Container Registry (ACR).
3.  Deploying/updating the services on Azure Kubernetes Service (AKS).

+----------------+       +-------------------+       +-----------------------+       +-----------------------+
|  Your Local PC |       | GitHub Repository |       | GitHub Actions        |       | Azure Kubernetes      |
|                |       | (My-Projects)     |       | (CI/CD Pipeline)      |       | Service (AKS)         |
| +----------+   |       |                   |       |                       |       |                       |
| | Frontend |   |       | +---------------+ |       | +-------------------+ |       |    +--------------+   |
| | Backend  |---+-----> | | Project8/     | |-----> | | Build & Push      | |-----> |    | Frontend Pod |   |
| +----------+   |       | |  frontend/    | |       | | (to ACR)          | |       |    |  (Nginx)     |<---|+
|                |       | |  backend/     | |       | +-------------------+ |       |    +--------------+   |  | Public IP
| +----------+   |       | |  *.yaml       | |       |                       |       |                       |  | (Load Balancer)
| | .github/   |---+-----> | +---------------+ |       | +-------------------+ |       |    +--------------+   |  |
| | workflows/ |   |       |                   |       | | Deploy to AKS     | |-----> |    | Backend Pod  |   |  |
| +----------+   |       |                   |       | +-------------------+ |       |    |   (Flask)    |---+
+----------------+       +-------------------+       +-----------------------+       +-----------------------+
git push                   on: push trigger           az & kubectl                  Running Apps

## 5. Prerequisites

* **Docker Desktop:** Essential for local development and testing of Docker images.
    * [Install Docker Desktop](https://docs.docker.com/get-docker/)
* **Azure Account:** An active Microsoft Azure subscription.
    * [Sign up for a free Azure account](https://azure.microsoft.com/en-in/free/)
* **Azure CLI:** The command-line tool for managing Azure resources.
    * [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
    * Verify installation: `az --version`
* **`kubectl`:** The command-line tool for interacting with Kubernetes clusters.
    * Install via Azure CLI: `az aks install-cli`
    * Verify installation: `kubectl version --client`
* **GitHub Account & Repository:**
* **Git:** For version control and interacting with GitHub.

## 6. Step-by-Step Deployment Guide

### Phase 0: Create the Project Structure Locally

1.  **Clone this GitHub Repository:**
    ```bash
    cd ~
    git clone [https://github.com/manoj-2606/My-Projects.git](https://github.com/manoj-2606/My-Projects.git)
    cd My-Projects/
    ```
    You are now in `~/My-Projects/`.

2.  **Create a New Project Directory for Project 8:**
    ```bash
    mkdir Project8
    cd Project8
    ```
    Your current directory is `~/My-Projects/Project8/`.

3.  **Create the Frontend Service (`frontend/`):**
    * Create directory: `mkdir frontend && cd frontend`
    * Create `index.html`, The file is presented in this path -> Project8/frontend
    * Create `Dockerfile`, The file is also presented in this path -> Project8/frontend
    * Go back to the Project8 root: `cd ..`

4.  **Create the Backend Service (`backend/`):**
    * Create directory: `mkdir backend && cd backend`
    * Create `app.py`, The file is presented in this path -> Project8/backend
    * Create `requirements.txt`, The file is also presented in this path -> Project8/frontend
    * Create `Dockerfile`, The file is also presented in this path -> Project8/frontend
    * Go back to the Project8 root: `cd ..`
  
### Phase 1: Azure Setup (Resource Group, ACR, and Docker Login)

1.  **Log in to Azure CLI:**
    ```bash
    az login
    az account set --subscription "<Your Azure Subscription Name or ID>"
    ```

2.  **Create a Resource Group:**
    ```bash
    az group create --name aks-dev-rg --location centralindia
    ```
    *(Adjust `centralindia` to your preferred Azure region).*

3.  **Create Azure Container Registry (ACR):**
    ```bash
    az acr create --resource-group aks-dev-rg --name aksdev007 --sku Basic --admin-enabled true
    ```
    * **Important:** Replace `aksdev007` with your **globally unique name** for your ACR.

4.  **Get Your ACR Login Server Name:**
    ```bash
    az acr show --name aksdev007 --query loginServer --output tsv
    ```
    Copy the output (e.g., `aksdev007.azurecr.io`). This is your `<your-acr-login-server>`.

5.  **Log in to ACR from Docker CLI (for initial manual push/verification):**
    You'll need the ACR username and password from the Azure portal (navigate to your ACR -> "Access keys").
    ```bash
    docker login <your-acr-login-server> -u <your-acr-username> -p <your-acr-password>
    ```

### Phase 2: Create Azure Service Principal (for GitHub Actions Authentication)

This secure identity allows GitHub Actions to interact with your Azure subscription.

1.  **Create the Service Principal:**
    ```bash
    az ad sp create-for-rbac --name "github-aks-sp-project8" --role contributor --scopes /subscriptions/<Your-Subscription-ID>/resourceGroups/aks-dev-rg --json-auth
    ```
    * Replace `<Your-Subscription-ID>` with your actual Azure Subscription ID.
    * **Carefully copy the entire JSON output from this command.** This JSON string will be used as your GitHub Secret.

### Phase 3: Add Service Principal Credentials to GitHub Secrets
1.  **Go to your GitHub repository:** `https://github.com/manoj-2606/My-Projects`
2.  Click on **"Settings"** tab.
3.  In the left sidebar, click on **"Secrets and variables"** and then **"Actions"**.
4.  Click on **"New repository secret"**.
5.  Create a secret named **`AZURE_CREDENTIALS`**.
6.  **Paste the entire JSON output** from Phase 2, Step 1 into the "Secret value" field.
7.  Click **"Add secret"**.

### Phase 4: Create Kubernetes Manifests (YAML Files) for Project 8

These YAML files define how Kubernetes will deploy and expose your applications. They include a placeholder (`IMAGE_TAG_PLACEHOLDER`) that GitHub Actions will dynamically replace with the Git commit SHA.

Create these files in your `~/My-Projects/Project8/` directory. [The files are placed in path -> My-Projects/Project8]

**Important:** In both YAMLs, replace `<your-acr-login-server>` with your actual ACR login server name (e.g., `aksdevacr007.azurecr.io`).

### Phase 5: Commit Initial Project Files to GitHub

This push establishes the `Project8` folder structure and its initial content on your GitHub repository.

1.  **Navigate to the root of your `My-Projects` repository:**
    ```bash
    cd ~/My-Projects
    ```
2.  **Add all new Project8 files:**
    ```bash
    git add Project8/
    ```
3.  **Commit the changes:**
    ```bash
    git commit -m "Initial commit for Project 8: AKS Multi-App structure"
    ```
4.  **Push to GitHub:**
    ```bash
    git push origin main
    ```
    *(Remember to use your Personal Access Token (PAT) if prompted for password).*

### Phase 6: Create the GitHub Actions Workflow File for Project 8

This YAML file defines the CI/CD pipeline.

1.  **Ensure you are in the root of your cloned `My-Projects` repository:**
    ```bash
    cd ~/My-Projects
    ```

2.  **Create the Workflow Directory:**
    ```bash
    mkdir -p .github/workflows
    cd .github/workflows
    ```

3.  **Create the Workflow File (`deploy-project8-aks.yml`):**
    ```bash
    nano deploy-project8-aks.yml
    ```
    The File is placed in the path -> My-Projects/.github/workflows
    **Crucial:** **Double-check and replace the placeholders in the `env` section** (`RESOURCE_GROUP`, `AKS_CLUSTER_NAME`, `ACR_NAME`, `ACR_LOGIN_SERVER`) with your actual Azure resource names.

### Phase 7: Create AKS Cluster with Managed Identity

This cluster needs to be active *before* the GitHub Actions workflow attempts to deploy to it.

1.  **Create AKS Cluster:**
    ```bash
    az aks create \
        --resource-group aks-dev-rg \
        --name myakscluster \
        --node-count 1 \
        --generate-ssh-keys \
        --enable-managed-identity \
        --attach-acr aksdev007
    ```
    * `--name myakscluster`: Your AKS cluster name.
    * `--attach-acr aksdev007`: Grants the AKS cluster's managed identity the `AcrPull` role on your ACR.

    *(This command will take some time to complete.)*

2.  **Get AKS Cluster Credentials (for manual `kubectl` checks if needed):**
    ```bash
    az aks get-credentials --resource-group aks-dev-rg --name myakscluster --overwrite-existing
    ```

### Phase 8: Trigger the CI/CD Pipeline

This final push will send the new workflow file to GitHub and, because it's a change within `.github/workflows`, it will trigger the pipeline.

1.  **Navigate back to the root of your `My-Projects` repository:**
    ```bash
    cd ~/My-Projects
    ```
2.  **Add and commit the new workflow file:**
    ```bash
    git add .github/workflows/deploy-project8-aks.yml
    git commit -m "Add GitHub Actions CI/CD pipeline for Project 8 AKS deployment"
    ```
3.  **Push the commit to GitHub:**
    ```bash
    git push origin main
    ```
    *(Remember to use your Personal Access Token (PAT) if prompted for password).*

### Phase 9: Monitor the Workflow Run on GitHub

1.  **Go to your GitHub repository:** `https://github.com/------/`
2.  Click on the **"Actions"** tab.
3.  You should now see a new workflow run initiated, named "Build, Push, and Deploy Project 8 to AKS". Click on it to watch the jobs execute.

## 7. Troubleshooting Journey: Overcoming Challenges

This project presented several common challenges in CI/CD and Kubernetes deployments. Understanding these and their solutions is key to becoming proficient.

### Challenge 1: GitHub Push Authentication (Password Deprecation)

* **Problem:** Initial `git push` attempts failed with "Support for password authentication was removed."
* **Diagnosis:** GitHub no longer allows using your account password directly for Git operations over HTTPS.
* **Solution:** Generated a **Personal Access Token (PAT)** from GitHub's developer settings with `repo` scope and used this PAT as the password when prompted during `git push`.

### Challenge 2: GitHub Actions Workflow Not Triggering

* **Problem:** The `deploy-project8-aks.yml` file was present on GitHub, but no workflow runs appeared in the "Actions" tab after its initial push.
* **Diagnosis:** The `on: push: paths: 'Project8/**'` filter in the workflow YAML meant that only pushes containing changes *within the `Project8` directory* would trigger the pipeline. The initial commit adding the workflow file itself was not seen as a change *inside* `Project8`.
* **Solution:** Made a small, innocuous change to a file within `Project8` (e.g., `frontend/index.html`), committed it, and pushed it. This new commit satisfied the `paths` filter, successfully triggering the workflow.

### Challenge 3: AKS ImagePullBackOff / Unauthorized / Image Not Found

* **Problem:** AKS pods failed to start with `ImagePullBackOff` or `ErrImagePull`, and `kubectl describe pod` showed "401 Unauthorized" and "not found" errors when trying to pull images from ACR.
* **Diagnosis:**
    1.  **Image Not Found:** The most immediate cause was that the Docker images (specifically `aks-backend:latest`) were not actually present in the Azure Container Registry under the exact name/tag specified. This usually indicates a failed `docker push` or incorrect tagging during the local build/push phase.
    2.  **Authorization Failure:** Even if the image existed, the AKS cluster's managed identity might not have had the `AcrPull` role assigned correctly or immediately.
* **Solution:**
    1.  **Verified Image Presence:** Thoroughly checked the ACR in the Azure Portal -> "Repositories" to confirm `aks-frontend-p8:latest` and `aks-backend-p8:latest` were indeed there. If not, re-executed the `docker build` and `docker push` commands (Phase 3) with extreme care, watching for any errors.
    2.  **Explicit `AcrPull` Role Assignment:** Ensured the AKS cluster's managed identity had the `AcrPull` role on the ACR by explicitly running `az role assignment create` (as detailed in Phase 4, Step 1 explanation). The `--attach-acr` flag during `az aks create` is designed to do this, but manual verification/re-assignment is a robust troubleshooting step.
    3.  After verifying/correcting, deleted the problematic pods (`kubectl delete pod <pod-name>`) to force Kubernetes to create new ones with the correct permissions.

### Challenge 4: Kubernetes YAML Indentation Error (`imagePullPolicy`)

* **Problem:** The GitHub Actions workflow failed during the `kubectl apply` step with a `BadRequest` error, specifically: `unknown field "spec.template.spec.imagePullPolicy"`.
* **Diagnosis:** This is a strict YAML parsing error. The `imagePullPolicy` field was incorrectly indented in the `frontend-deployment.yaml` and `backend-deployment.yaml` files. It was placed at the same level as the `containers` list, instead of being nested *inside* the container definition.
* **Solution:** Corrected the indentation of `imagePullPolicy: Always` to be a direct property of the `container` object, one level deeper in the YAML structure (as shown in Phase 4, Step 1 and 2). Pushed these corrected YAMLs to trigger a new workflow run.

## 8. Final Output & Verification

Upon successful completion of the GitHub Actions workflow, your application is deployed to AKS.

1.  **Get the External IP of the Frontend Service:**
    Open your terminal and run:
    ```bash
    kubectl get service frontend-service-p8
    ```
    Look for the `EXTERNAL-IP` in the output. It might take a few minutes for Azure to provision the Load Balancer and assign an IP.

2.  **Access the Application:**
    Open your web browser and navigate to `http://<EXTERNAL-IP>`, replacing `<EXTERNAL-IP>` with the IP address obtained from the previous step.

    You should see the output:
    ```
    Hello from the Frontend! (Project 8 - Test 2)
    This page is served by the Frontend container.
    ```
    This confirms that the entire CI/CD pipeline, from code push to AKS deployment, is fully functional.

## 9. Clean Up Azure Resources

To avoid incurring ongoing costs, always clean up your Azure resources when the project is complete.

1.  **Delete the entire Resource Group:**
    This command will delete your AKS cluster, ACR, and all other resources within the `aks-dev-rg` resource group.
    ```bash
    az group delete --name aks-dev-rg --yes --no-wait
    ```
    *(Note: This process can take several minutes to complete in Azure's backend.)*


## Az-RG Image

![Az-RG Image](https://github.com/manoj-2606/My-Projects/blob/12c1ac1c2499b791ec10effe13eb82be8990d6e5/Project8/Az-RG.png)

## Pipeline Deployment Image

![Pipeline Deployment Image](https://github.com/manoj-2606/My-Projects/blob/5e7c6a6138b201a1d3017856d17066a73ef346ee/Project8/Pipeline%20Deployment.png)

## App-Output Image

![App-Output Image](https://github.com/manoj-2606/My-Projects/blob/12c1ac1c2499b791ec10effe13eb82be8990d6e5/Project8/ForntEnd-%20Output.png)
---
