# DevOps News Post Deployment on Azure App Service

This project demonstrates how to deploy a simple, static HTML website (a DevOps news post) as a Docker container to Azure App Service. It showcases the fundamental process of containerizing a web application and deploying it to the cloud using Azure services.

## Project Goal

The primary goal of this project is to illustrate a common cloud deployment methodology:
1.  **Containerize a local application:** Package a web application into a Docker image.
2.  **Store the image in a cloud registry:** Push the Docker image to Azure Container Registry (ACR).
3.  **Deploy the container to a managed cloud service:** Run the Docker image on Azure App Service to make it publicly accessible.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

* **Docker Desktop:** [Install Docker](https://docs.docker.com/get-docker/) (Includes Docker Engine and Docker Compose)
* **Azure Account:** A Microsoft Azure subscription. You can sign up for a [free Azure account](https://azure.microsoft.com/en-in/free/).

## Project Structure

devops-news/
├── index.html      # The static HTML content for the news post
└── Dockerfile      # Instructions for building the Docker image

## How to Run

Follow these steps to run the application:

### Phase 1: Prepare Your Local Web Application

1.  **Create the Project Directory:**
    Open your terminal or command prompt and create a new directory for your project:

    ```bash
    mkdir devops-news
    cd devops-news
    ```

2.  **Create the `index.html` file:**
    Inside the `devops-news` directory, create a file named `index.html` and paste the following HTML content into it: The code was placed in the Project

3.  **Create the `Dockerfile`:**
    In the same `devops-news` directory, create a file named `Dockerfile` and add the following content:

    ```dockerfile
    FROM nginx:alpine
    COPY index.html /usr/share/nginx/html/
    EXPOSE 80
    ```
    * **`FROM nginx:alpine`**: We use a lightweight Nginx web server image as our base. Nginx is an efficient web server commonly used for serving static content.
    * **`COPY index.html /usr/share/nginx/html/`**: This command copies your `index.html` file from your local project directory into the container's default Nginx web serving directory.
    * **`EXPOSE 80`**: This declares that the container listens on port 80, which is the standard HTTP port.

### Phase 2: Build and Push Your Docker Image to Azure Container Registry (ACR)
Azure Container Registry is a managed Docker image registry service in Azure. It's where your custom Docker images are stored securely before deployment.

1.  **Sign in to the Azure Portal:**
    Open your web browser and go to [https://portal.azure.com/](https://portal.azure.com/) and sign in with your Azure account.

2.  **Create a Resource Group:**
    * Click on "Resource groups" or search for it.
    * Click "+ Create".
    * Choose your **Subscription**.
    * Enter a **Resource group name** (e.g., `devops-rg`).
    * Select a **Region** (e.g., `Central India`).
    * Click "Review + create" and then "Create".

3.  **Create an Azure Container Registry:**
    * In the Azure portal, click "+ Create a resource".
    * Search for "Container Registry" and select it.
    * Click "Create".
    * Choose your **Subscription** and the **Resource group** you just created (e.g., `devops-rg`).
    * Enter a **Registry name** (e.g., `yourdevopsacr` - this name must be globally unique across Azure).
    * Choose the same **Location** as your resource group.
    * For **SKU**, select "Basic" for cost-effectiveness during development.
    * For **Admin user**, set it to **"Enable"**. This provides credentials for Docker to push images.
    * Click "Review + create" and then "Create".

4.  **Note Down ACR Credentials:**
    Once your ACR is deployed, navigate to it in the Azure portal. Under "Settings", click on "Access keys". Note down the **Login server**, **Username**, and **Password**. You will need these for the next step.

5.  **Log in to Azure Container Registry using Docker CLI:**
    Open your terminal/command prompt and replace the placeholders with your actual ACR details:

    ```bash
    docker login <your-acr-name>.azurecr.io -u <your-acr-username> -p <your-acr-password>
    ```
    You should see a "Login Succeeded" message.

6.  **Build Your Docker Image:**
    Ensure you are in the `devops-news` directory (where your `Dockerfile` is). Build the image and tag it with your ACR's login server:

    ```bash
    docker build -t <your-acr-name>.azurecr.io/devops-news-app:latest .
    ```
    * `<your-acr-name>.azurecr.io`: Your ACR's "Login server" (e.g., `mydevopsacr.azurecr.io`).
    * `devops-news-app`: The name of the repository within your ACR for this application.
    * `latest`: The tag for your image (can be a version number like `v1.0`).
    * `.`: Indicates the Dockerfile is in the current directory.

7.  **Push Your Docker Image to ACR:**
    Upload your newly built Docker image to your Azure Container Registry:

    ```bash
    docker push <your-acr-name>.azurecr.io/devops-news-app:latest
    ```

### Phase 3: Create and Configure Azure App Service

Azure App Service is a fully managed platform for building, deploying, and scaling web apps. We'll configure it to pull and run your Docker image from ACR.

1.  **Create an Azure App Service:**
    * In the Azure portal, click "+ Create a resource".
    * Search for "App Service" and select it.
    * Click "Create".
    * Choose your **Subscription** and the **Resource group** you created (e.g., `devops-rg`).
    * Enter an **App Service name** (e.g., `devops-news-web-app` - this name must be globally unique).
    * For **Publish**, select "Docker Container".
    * Choose a **Region** (same as your resource group and ACR for best performance).
    * For **Operating System**, select "Linux".
    * For **App Service Plan**, select a suitable plan (e.g., "Basic" or "Free" for testing).
    * Click "Next: Docker >" (or the "Container" tab).

2.  **Configure Docker Container Settings:**
    * For **Image Source**, select "Azure Container Registry".
    * For **Registry**, select your ACR from the dropdown (e.g., `yourdevopsacr`).
    * For **Image**, select `devops-news-app`.
    * For **Tag**, select `latest`.
    * You can leave the **Startup Command** blank, as our `Dockerfile` already specifies how to run Nginx.
    * Click "Review + create" and then "Create".

### Phase 4: Access Your Deployed Application

1.  **Wait for Deployment:** Azure will now provision your App Service and pull your Docker image. This process typically takes a few minutes. You can monitor the deployment status in the Azure portal notifications.

2.  **Browse to Your App Service:**
    Once the deployment is successful, navigate to your App Service in the Azure portal (you can find it in your resource group or by searching its name). On the "Overview" page, you will see a **URL** (e.g., `https://devops-news-web-app.azurewebsites.net`). Click on this URL.

    You should now see your static DevOps news post live on Azure App Service!

## Updating Your Application

If you make changes to your local `index.html` file (or any other files in your project), you need to re-deploy these changes to Azure. This involves:

1.  **Rebuild the Docker Image:**
    ```bash
    docker build -t <your-acr-name>.azurecr.io/devops-news-app:latest .
    ```

2.  **Push the New Image to ACR:**
    ```bash
    docker push <your-acr-name>.azurecr.io/devops-news-app:latest
    ```

3.  **Restart the App Service:** Azure App Service will typically detect the new `latest` image and restart automatically within a few minutes. To force an immediate update, go to your App Service in the Azure portal and click the "Restart" button on the "Overview" page.

This process ensures that your App Service pulls the latest version of your container image and reflects your updates.

## Azure Resources

![Azure Resources](https://github.com/manoj-2606/My-Projects/blob/8c410e19e2040bd243910af6eda1189b46bb00ff/Project6/Azure%20Resources.png)



---
