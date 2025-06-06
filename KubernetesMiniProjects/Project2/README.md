# Project 2: Exposing Your Application to the Outside World (NodePort & LoadBalancer)

## Project Overview

Building upon Project 1's foundation of internal application deployment, this project focuses on making a deployed web application accessible from outside the Kubernetes cluster. It explores two primary Kubernetes Service types designed for external exposure: `NodePort` and `LoadBalancer`. By completing this project, one gains practical experience in exposing services to the internet and understanding the underlying mechanisms in a cloud environment like Azure Kubernetes Service (AKS).

## Learning Objectives

* **Understanding Service Types:** Differentiate between `ClusterIP` (internal), `NodePort`, and `LoadBalancer` (external) Service types.
* **NodePort Services:** Learn how to expose an application on a static port on each cluster node's IP address. Understand its use cases and limitations for direct external access in cloud environments.
* **LoadBalancer Services:** Master the most common and robust method for exposing internet-facing applications in cloud-hosted Kubernetes clusters, leveraging cloud provider-managed load balancers.
* **External Access Testing:** Practice retrieving and utilizing external IP addresses to verify public accessibility of deployed applications.
* **Continued `kubectl` Proficiency:** Further develop skills in managing Kubernetes resources with essential `kubectl` commands.

## Prerequisites

Before starting this project, ensure you have:

1.  **Azure CLI:** Installed and authenticated (`az login`).
2.  **`kubectl`:** Configured to interact with your Azure subscription.
3.  An active Azure subscription.

---

## Project Steps: A Complete Walkthrough

### Phase 0: Re-create AKS Cluster and Deploy Nginx Application

Since we perform a full cleanup after each project for clarity and cost management, we start by setting up a fresh AKS cluster and deploying our Nginx application as a Deployment, identical to the initial steps of Project 1.

1.  **Login to Azure CLI:**
    ```bash
    az login
    az account set --subscription "<Your Azure Subscription Name or ID>" # Replace with your subscription
    ```

2.  **Create an Azure Resource Group:**
    ```bash
    az group create --name k8s-basics-rg --location centralindia # Or your preferred region
    ```

3.  **Create the AKS Cluster:**
    ```bash
    az aks create \
        --resource-group k8s-basics-rg \
        --name basic-k8s-cluster \
        --node-count 1 \
        --generate-ssh-keys
    ```
    *This command will take several minutes to complete.*

4.  **Get AKS Cluster Credentials:**
    ```bash
    az aks get-credentials --resource-group k8s-basics-rg --name basic-k8s-cluster --overwrite-existing
    ```

5.  **Create an Nginx Deployment:**
    ```bash
    kubectl create deployment my-nginx-app --image=nginx
    ```
    * **Expected Output:** `deployment.apps/my-nginx-app created`

6.  **Verify Pod is Running:**
    ```bash
    kubectl get pods
    ```
    * **Expected Output:** `my-nginx-app-<some-hash>` with `Running` status.

### Phase 1: Exposing with NodePort Service

A `NodePort` Service exposes your application on a static port across all worker nodes in your cluster. This means you can access the application by connecting to *any* node's IP address on that specific NodePort.

1.  **Create a NodePort Service for Nginx:**
    ```bash
    kubectl expose deployment my-nginx-app --port=80 --target-port=80 --name=nginx-nodeport-service --type=NodePort
    ```
    * **`--name=nginx-nodeport-service`**: A distinct name for this Service.
    * **`--type=NodePort`**: Specifies the Service type.
    * **Expected Output:** `service/nginx-nodeport-service exposed`

2.  **Inspect the NodePort Service:**
    ```bash
    kubectl get services nginx-nodeport-service
    ```
    * **Expected Output:** You'll see `nginx-nodeport-service` with `TYPE: NodePort`. Note the `80:3XXXX/TCP` under `PORT(S)`. The `3XXXX` is the dynamically assigned NodePort (typically in the 30000-32767 range). Make a note of this port.

    ```bash
    kubectl describe service nginx-nodeport-service
    ```
    * **Expected Output:** Detailed Service description showing `NodePort` mapping.

3.  **Attempt to Get the Public IP of your AKS Node (Troubleshooting Highlight):**
    While `NodePort` exposes on the node's IP, in a default AKS setup, individual nodes generally only have *private* IP addresses within the cluster's virtual network. Direct external access to these NodePorts via a node's public IP is not common without additional network configuration (like an Azure Load Balancer or Ingress Controller).
    ```bash
    az vmss list-instance-public-ips \
        --resource-group MC_k8s-basics-rg_basic-k8s-cluster_centralindia \
        --name aks-nodepool1-31666821-vmss \
        --query "[0].ipAddress" \
        --output tsv
    ```
    * **Note:** You must replace `MC_k8s-basics-rg_basic-k8s-cluster_centralindia` and `aks-nodepool1-31666821-vmss` with your exact managed resource group name and VM Scale Set name, respectively. (See Troubleshooting section for how to find these exact names).
    * **Actual Outcome:** This command might **return no output**, as the individual node VMs in AKS typically do not have directly assigned public IPs by default. This is an expected behavior and highlights why `LoadBalancer` is the preferred method for external exposure in cloud environments.

### Phase 2: Exposing with LoadBalancer Service

The `LoadBalancer` Service type is the standard method for exposing applications to the internet in cloud Kubernetes environments. It provisions a cloud provider's load balancer and assigns a public IP address to it, which then distributes traffic to your application's Pods.

1.  **Delete the NodePort Service (Optional but Recommended):**
    To avoid confusion and ensure a clean test, it's good practice to remove the previous external exposure mechanism.
    ```bash
    kubectl delete service nginx-nodeport-service
    ```
    * **Expected Output:** `service "nginx-nodeport-service" deleted` (or "not found" if already deleted).

2.  **Create a LoadBalancer Service for Nginx:**
    ```bash
    kubectl expose deployment my-nginx-app --port=80 --target-port=80 --name=nginx-loadbalancer-service --type=LoadBalancer
    ```
    * **`--name=nginx-loadbalancer-service`**: A distinct, clear name for this Service.
    * **`--type=LoadBalancer`**: Crucially, this instructs Kubernetes to provision an Azure Load Balancer.
    * **Expected Output:** `service/nginx-loadbalancer-service exposed`

3.  **Inspect the LoadBalancer Service and Get External IP:**
    Provisioning the Azure Load Balancer and assigning an external IP takes a minute or two. Use the `--watch` flag to see the IP appear automatically.
    ```bash
    kubectl get services nginx-loadbalancer-service --watch
    ```
    * Let this run until an IP appears under the `EXTERNAL-IP` column.
    * **Expected Output:** An IP address (e.g., `20.123.45.67`) will eventually populate under `EXTERNAL-IP`. Press `Ctrl+C` once it appears.

    You can also get more details about the service:
    ```bash
    kubectl describe service nginx-loadbalancer-service
    ```
    * **Expected Output:** Details including the `LoadBalancer Ingress` with the assigned public IP.

4.  **Test External Access (LoadBalancer):**
    Open your web browser and navigate to the `EXTERNAL-IP` obtained in the previous step.
    ```
    http://<LOAD_BALANCER_EXTERNAL_IP>
    ```
    * **Replace `<LOAD_BALANCER_EXTERNAL_IP>`** with the actual IP.
    * **Expected Outcome:** You should successfully see the "Welcome to nginx!" page, confirming external access via the LoadBalancer.

### Phase 3: Clean Up Project 2 Resources

Always clean up your cloud resources to prevent unnecessary charges.

1.  **Delete the Kubernetes Deployment:**
    ```bash
    kubectl delete deployment my-nginx-app
    ```
    * **Expected Output:** `deployment.apps "my-nginx-app" deleted`

2.  **Delete the LoadBalancer Service:**
    This will also de-provision the Azure Load Balancer resource.
    ```bash
    kubectl delete service nginx-loadbalancer-service
    ```
    * **Expected Output:** `service "nginx-loadbalancer-service" deleted`

3.  **Verify Kubernetes Resources are Gone:**
    ```bash
    kubectl get pods
    kubectl get deployments
    kubectl get services
    ```
    * **Expected Output:** "No resources found" (except for the default `kubernetes` service).

4.  **Delete the Azure Resource Group:**
    This removes your entire AKS cluster and all its underlying Azure resources.
    ```bash
    az group delete --name k8s-basics-rg --yes --no-wait
    ```
    *This command completes quickly, but Azure performs the deletion in the background, which may take several minutes.*

---

## Troubleshooting Encountered During Projects 1 & 2

During the course of these foundational projects, a couple of common Kubernetes/Azure interaction challenges were faced and successfully resolved:

1.  **`kubectl run` creating a Pod instead of a Deployment (Project 1):**
    * **Issue:** Initially, `kubectl run my-nginx-app --image=nginx --port=80` created a standalone `Pod` named `my-nginx-app` instead of a `Deployment`. This led to `kubectl get deployments` showing "No resources found."
    * **Reason:** The behavior of `kubectl run` regarding whether it creates a Pod or a Deployment has changed across `kubectl` versions. In some newer versions, if specific flags (like `--restart=Always` or `--generator`) are not provided, it might default to a standalone Pod.
    * **Resolution:** Deleted the standalone Pod (`kubectl delete pod my-nginx-app`) and explicitly used `kubectl create deployment my-nginx-app --image=nginx` to ensure a Deployment resource was created, which is the proper way to manage an application's lifecycle in Kubernetes.

2.  **`kubectl expose` with incorrect Service name (Project 1):**
    * **Issue:** The Service was accidentally named using the full Pod name (`my-nginx-app-5d64458c64-8lvfj`) instead of the intended simple name (`my-nginx-service`). This caused `curl my-nginx-service` to fail with "Could not resolve host."
    * **Reason:** Kubernetes internal DNS resolves Services based on their *actual name*. If the Service is named incorrectly, other applications cannot find it.
    * **Resolution:** Deleted the incorrectly named Service (`kubectl delete service my-nginx-app-5d64458c64-8lvfj`) and re-created it with the correct, simple name (`kubectl expose deployment my-nginx-app --name=my-nginx-service ...`).

3.  **`az vmss list-instance-public-ips` not returning an IP (Project 2):**
    * **Issue:** The command to get the public IP of the AKS node (`az vmss list-instance-public-ips`) returned no output.
    * **Reason:** In a default AKS configuration, individual worker node VMs typically do not have directly assigned public IP addresses. Instead, they operate with private IPs within the cluster's virtual network. External public access for applications in AKS is usually handled by Azure Load Balancers (provisioned via `LoadBalancer` Service type) or Ingress Controllers, which receive the public IP and then route traffic to the internal node IPs or Pods.
    * **Resolution:** Understood this expected behavior and proceeded with the `LoadBalancer` Service type, which successfully provisioned an Azure Load Balancer with a public IP for external application access.

## Nginx welcome page Image

![Az-RG Image](https://github.com/manoj-2606/My-Projects/blob/b77ec610ba345f7ddd26a5d9ce26183abe1093aa/KubernetesMiniProjects/Project2/Output.png)

---
