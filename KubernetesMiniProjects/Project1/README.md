# Project 1: The "Hello World" of Pods & Deployments in Kubernetes

## Project Overview

This project serves as a foundational "Hello World" example for deploying and managing a simple web application (Nginx) on a Kubernetes cluster. It introduces core Kubernetes concepts such as Pods, Deployments, and Services, and familiarizes the user with essential `kubectl` commands for interacting with the cluster.

The goal is to understand how applications are packaged, deployed, internally exposed, and managed within a Kubernetes environment before tackling external access or more complex stateful applications.

## Learning Objectives

Upon completing this project, you will have a solid understanding of:

* **Kubernetes Pods:** The smallest deployable units that encapsulate one or more containers.
* **Kubernetes Deployments:** How to declare and manage the desired state of your applications, ensuring reliability and scalability.
* **Kubernetes Services (ClusterIP):** Providing stable internal networking for applications within the cluster, enabling service discovery and load balancing.
* **Essential `kubectl` Commands:** Gaining hands-on proficiency with `kubectl` for resource creation, inspection, logging, and deletion.
* **Basic Cloud Resource Provisioning:** Setting up a minimal Azure Kubernetes Service (AKS) cluster.

## Prerequisites

Before you begin, ensure you have the following installed and configured on your local machine:

1.  **Azure CLI:** Used to interact with Azure to create and manage the AKS cluster.
    * [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2.  **`kubectl`:** The command-line tool for running commands against Kubernetes clusters.
    * `kubectl` is usually installed automatically when you set up `az aks get-credentials`.
3.  **Azure Account:** An active Azure subscription.

---

## Project Steps: A Complete Walkthrough

Follow these steps meticulously. Each command builds upon the previous one to demonstrate the core concepts.

### Phase 0: Set Up Your Azure Kubernetes Service (AKS) Cluster

First, we need a Kubernetes cluster. We will create a small, cost-effective AKS cluster in Azure.

1.  **Login to Azure CLI:**
    ```bash
    az login
    ```
    Follow the prompts to complete the login.
    ```bash
    az account set --subscription "<Your Azure Subscription Name or ID>"
    ```
    Replace `<Your Azure Subscription Name or ID>` with your actual subscription details.

2.  **Create an Azure Resource Group:**
    This group will hold all resources related to your AKS cluster.
    ```bash
    az group create --name k8s-basics-rg --location centralindia
    ```
    * **`--name k8s-basics-rg`**: Name of your resource group.
    * **`--location centralindia`**: Azure region for your resources. You can change this to a region closer to you (e.g., `eastus`, `southeastasia`).

3.  **Create the AKS Cluster:**
    This command provisions a minimal AKS cluster with a single node.
    ```bash
    az aks create \
        --resource-group k8s-basics-rg \
        --name basic-k8s-cluster \
        --node-count 1 \
        --generate-ssh-keys
    ```
    * **`--name basic-k8s-cluster`**: Name of your AKS cluster.
    * **`--node-count 1`**: Creates a single worker node (for cost efficiency).
    * **`--generate-ssh-keys`**: Automatically generates SSH keys for node access (good practice).
    * **Expected Output:** This command will take several minutes to complete. You'll see JSON output once it's done.

4.  **Get AKS Cluster Credentials:**
    Configure your local `kubectl` to connect to your newly created AKS cluster.
    ```bash
    az aks get-credentials --resource-group k8s-basics-rg --name basic-k8s-cluster --overwrite-existing
    ```
    * **`--overwrite-existing`**: Ensures your `kubectl` context points to this new cluster.
    * **Expected Output:** `Merged "basic-k8s-cluster" as current context in /home/manoj/.kube/config` (path may vary).

### Phase 1: Deploy a Simple Nginx Application (Deployment)

Now that the cluster is ready, we'll deploy an Nginx web server using a Kubernetes Deployment.

1.  **Create an Nginx Deployment:**
    This command tells Kubernetes to create a Deployment named `my-nginx-app` using the `nginx` Docker image.
    ```bash
    kubectl create deployment my-nginx-app --image=nginx
    ```
    * **Expected Output:** `deployment.apps/my-nginx-app created`

### Phase 2: Inspect Your Pod and Deployment

Verify the deployment and understand the created resources.

1.  **List Pods:** Check the status of the Pod(s) created by your Deployment.
    ```bash
    kubectl get pods
    ```
    * **Expected Output:** You should see a Pod named `my-nginx-app-<some-hash>` (e.g., `my-nginx-app-5d64458c64-8lvfj`) with a `Running` status. It might take a few moments for the status to change from `ContainerCreating`.

2.  **List Deployments:** Confirm the Deployment resource itself is active.
    ```bash
    kubectl get deployments
    ```
    * **Expected Output:** `NAME           READY   UP-TO-DATE   AVAILABLE   AGE` followed by `my-nginx-app   1/1     1            1           <age>`

3.  **Describe Your Pod:** Get detailed information about your Nginx Pod.
    ```bash
    kubectl describe pod <name-of-your-nginx-pod>
    ```
    * **Replace `<name-of-your-nginx-pod>`** with the full name from `kubectl get pods` (e.g., `my-nginx-app-5d64458c64-8lvfj`).
    * **Expected Output:** Detailed YAML-like output showing Pod status, events, container info, etc. Look for `Status: Running` and `Containers: nginx`.

4.  **Describe Your Deployment:** Get detailed information about the Deployment resource.
    ```bash
    kubectl describe deployment my-nginx-app
    ```
    * **Expected Output:** Detailed output showing Deployment strategy, replica count, associated ReplicaSet, and Pod template.

5.  **View Pod Logs:** See the standard output from the Nginx container inside the Pod.
    ```bash
    kubectl logs <name-of-your-nginx-pod>
    ```
    * **Replace `<name-of-your-nginx-pod>`** with the full name from `kubectl get pods`.
    * **Expected Output:** Initial Nginx startup logs. You might not see much activity until requests are made to the server.

### Phase 3: Expose the Application Internally with a ClusterIP Service

Create a stable internal network endpoint for your Nginx application.

1.  **Create a ClusterIP Service for the Deployment:**
    This command creates a Service named `my-nginx-service` that routes traffic to your `my-nginx-app` Deployment on port 80.
    ```bash
    kubectl expose deployment my-nginx-app --port=80 --target-port=80 --name=my-nginx-service --type=ClusterIP
    ```
    * **`--name=my-nginx-service`**: This is the DNS name and service name other applications within the cluster will use.
    * **Expected Output:** `service/my-nginx-service exposed`

2.  **List Services:** Verify your new Service.
    ```bash
    kubectl get services
    ```
    * **Expected Output:** You should see `my-nginx-service` listed with `TYPE: ClusterIP` and a `CLUSTER-IP` address (e.g., `10.0.199.142`). You will also see the default `kubernetes` service.

3.  **Describe Your Service:** Get detailed information about the Service.
    ```bash
    kubectl describe service my-nginx-service
    ```
    * **Expected Output:** Detailed output showing the Service's IP, ports, and the `Selector` which links it to your `my-nginx-app` Pods.

### Phase 4: Test Internal Connectivity

Since `ClusterIP` Services are only accessible within the cluster, we'll test connectivity by running a temporary Pod and using `curl` to access our Nginx Service.

1.  **Run a temporary "debugger" Pod:**
    This creates a temporary Ubuntu Pod that we can use to run commands from within the cluster.
    ```bash
    kubectl run -it --rm --restart=Never debug-pod --image=ubuntu -- bash
    ```
    * **`--rm`**: Ensures the Pod is deleted automatically when you exit the shell.
    * **`--restart=Never`**: Ensures it's a standalone Pod, not a Deployment.
    * **Expected Output:** A new shell prompt: `root@debug-pod:/#` (you might see some `debconf` warnings, which are harmless for this context).

2.  **Inside the `debug-pod`'s shell, install `curl` and test:**
    First, update package lists and install `curl`. Then, use `curl` with your Service name.
    ```bash
    apt update && apt install -y curl
    curl my-nginx-service
    ```
    * **Expected Output for `curl my-nginx-service`:** The HTML content of the Nginx welcome page, confirming successful internal communication.

3.  **Exit the `debug-pod`'s shell:**
    ```bash
    exit
    ```
    * **Expected Output:** The `debug-pod` will terminate and be removed. You will return to your local terminal prompt.

### Phase 5: Clean Up Project 1 Resources

It's essential to clean up your Kubernetes resources to prevent unnecessary costs and maintain a tidy cluster.

1.  **Delete the Kubernetes Deployment:**
    This will delete the `my-nginx-app` Deployment and automatically terminate all associated Pods and ReplicaSets.
    ```bash
    kubectl delete deployment my-nginx-app
    ```
    * **Expected Output:** `deployment.apps "my-nginx-app" deleted`

2.  **Delete the Kubernetes Service:**
    This will delete the `my-nginx-service` ClusterIP Service.
    ```bash
    kubectl delete service my-nginx-service
    ```
    * **Expected Output:** `service "my-nginx-service" deleted`

3.  **Verify Kubernetes Resources are Gone:**
    Confirm that no related resources are still running.
    ```bash
    kubectl get pods
    kubectl get deployments
    kubectl get services
    ```
    * **Expected Output:** `No resources found in default namespace.` for pods and deployments. You will still see the default `kubernetes` service.

4.  **Delete the Azure Resource Group:**
    This will delete your entire AKS cluster and all its underlying Azure resources. This is the most important step for cost management.
    ```bash
    az group delete --name k8s-basics-rg --yes --no-wait
    ```
    * **`--yes`**: Confirms deletion without a prompt.
    * **`--no-wait`**: Returns control to your terminal immediately, allowing the deletion to proceed in the background.
    * **Expected Output:** No immediate confirmation, but the resource group will be queued for deletion.

---

You have now successfully completed **Project 1: The "Hello World" of Pods & Deployments** from start to finish, including documenting it for your GitHub!

Let me know when you've placed this `README.md` file in your repository and are ready to discuss **Project 2: Exposing Your Application to the Outside World (NodePort & LoadBalancer)**.
