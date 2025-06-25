# Azure DevOps & App Service CI/CD Projects

This repository documents my journey and practical application of Continuous Integration (CI) and Continuous Deployment (CD) principles using Azure DevOps and Azure App Services. It's structured into two main phases:

1.  **Azure Repos Fundamentals:** A deep dive into version control concepts within Azure DevOps.
2.  **Azure App Service CI/CD Implementation:** A hands-on project demonstrating automated deployment of a simple web application to Azure App Service.

---

## Table of Contents

* [Project 1: Azure Repos Fundamentals](#project-1-azure-repos-fundamentals)
    * [Overview](#overview)
    * [Key Learning Areas](#key-learning-areas)
* [Project 2: Azure App Service CI/CD Pipeline](#project-2-azure-app-service-cicd-pipeline)
    * [Project Goal](#project-goal)
    * [Architecture Flow](#architecture-flow)
    * [Demo Application](#demo-application)
    * [Azure Components Used](#azure-components-used)
    * [Setup Instructions (for replication)](#setup-instructions-for-replication)
        * [Prerequisites](#prerequisites)
        * [Step 1: Create Azure App Service](#step-1-create-azure-app-service)
        * [Step 2: Create Azure DevOps Service Connection](#step-2-create-azure-devops-service-connection)
        * [Step 3: Configure Azure Pipeline (`azure-pipelines.yml`)](#step-3-configure-azure-pipeline-azure-pipelinesyml)
    * [How to Run the CI/CD](#how-to-run-the-cicd)
* [Files in this Repository](#files-in-this-repository)
* [Future Enhancements](#future-enhancements)
* [Conclusion](#conclusion)

---

## Project 1: Azure Repos Fundamentals

### Overview

This phase focused on understanding the core concepts of version control within Azure Repos, a powerful component of Azure DevOps. It laid the groundwork for managing source code effectively in a collaborative environment. My learning involved using two separate repositories to practice different scenarios and concepts.

### Key Learning Areas

* **Version Control Systems (VCS):** Understanding the importance of tracking changes, collaboration, and rollback capabilities.
* **Git vs. TFVC:** A comparative study of distributed (Git) vs. centralized (TFVC) version control, including their respective pros and cons and appropriate use cases.
* **Branching Strategies:** Exploration of common branching models like Feature Branching, Gitflow, and Trunk-Based Development, and their implications for team workflows.
* **Pull Requests (PRs) & Code Reviews:** The role of PRs in code quality, collaboration, and enforcing branch policies.
* **Integration with CI/CD:** How source code changes in repositories trigger automated build and deployment pipelines.

*(Note: The detailed PPT outlines generated during this phase are conceptual and not included as physical files in this repository.)*

---

## Project 2: Azure App Service CI/CD Pipeline

### Project Goal

The primary goal of this project was to implement a fully automated Continuous Integration (CI) and Continuous Deployment (CD) pipeline. This pipeline automatically takes code changes from Azure Repos, builds them (in this case, packages static HTML), and deploys them to a live Azure App Service instance.

### Architecture Flow

The solution leverages the following simplified CI/CD flow:

`Azure Repos (Code Source)` &rarr; `Azure Pipelines (Build & Deploy Automation)` &rarr; `Azure App Service (Managed Web Hosting)`

* **Continuous Integration (CI):** Any push to the `main` branch in Azure Repos automatically triggers the pipeline to build and validate the code.
* **Continuous Deployment (CD):** Upon successful build, the pipeline proceeds to deploy the application to Azure App Service.

### Demo Application

The application used for this demo is a simple, colorful HTML page (`index.html`) designed to showcase live updates. It includes floating Azure DevOps and Azure App Service-themed elements to make the demonstration visually engaging.

### Azure Components Used

* **Azure Repos:** For source code management.
* **Azure Pipelines:** For defining and executing the CI/CD workflow (build, test, deploy).
* **Azure App Service:** A Platform-as-a-Service (PaaS) offering used to host the web application.

### Setup Instructions (for replication)

To replicate this project and demonstrate the CI/CD pipeline, follow these steps:

#### Prerequisites

* An Azure Subscription.
* An Azure DevOps Organization and Project.
* This repository cloned to your local machine, and then pushed to your Azure Repos project.

#### Step 1: Create Azure App Service

1.  Log in to the [Azure Portal](https://portal.azure.com/).
2.  Search for and select "App Services", then click "Create" > "Web App".
3.  Configure the Web App with the following (or similar) settings:
    * **Subscription:** Your Azure Subscription.
    * **Resource Group:** Create a new one (e.g., `my-appservice-demo-rg`).
    * **Name:** A globally unique name (e.g., `yourname-cicddemo-appservice`). This name will be used in the pipeline.
    * **Publish:** Code
    * **Runtime stack:** Select `HTML` (as the demo is a simple static HTML file).
    * **Operating System:** Linux
    * **Region:** Choose a region close to you (e.g., `Central India`).
    * **App Service Plan:** Create a new plan (e.g., `yourname-cicddemo-plan`) and select a free or basic tier (e.g., F1 Free or B1 Basic).
4.  Review and create the App Service. Note its URL once deployed.

#### Step 2: Create Azure DevOps Service Connection

1.  Go to your Azure DevOps Project (`https://dev.azure.com/<your-organization>/<your-project>`).
2.  Navigate to **Project settings** (bottom left).
3.  Under "Pipelines," click **"Service connections."**
4.  Click **"Create service connection"**.
5.  Select `Azure Resource Manager`, then `Service principal (automatic)`.
6.  Set **Scope Level** to `Subscription`.
7.  Select your **Subscription** and the **Resource Group** where you created your App Service.
8.  Give the service connection a clear name (e.g., `AzureForCICDAppService`). **This name is critical and must match what you put in your `azure-pipelines.yml` later.**
9.  Click "Save" and ensure the connection is verified.

#### Step 3: Configure Azure Pipeline (`azure-pipelines.yml`)

1.  In your Azure DevOps project, navigate to **Pipelines** > **Pipelines**.
2.  If you haven't already, create a new pipeline pointing to the `azure-pipelines.yml` file in *this* repository (which should now be in your Azure Repos).
3.  Edit the `azure-pipelines.yml` file to ensure the `Deploy` stage is correctly configured. You will find the complete `azure-pipelines.yml` file in this repository. Ensure you update the following placeholders:

    * **`azureSubscription`:** Replace `'AzureForCICDAppService'` with the exact name of the Service Connection you created in Azure DevOps.
    * **`appName`:** Replace `'yourname-cicddemo-appservice'` with the exact name of the Azure App Service you created in the Azure Portal.
    * **HTML File Name in Test Script:** The test script within the `BuildAndTest` stage expects `index.html` (if you renamed your file).

### How to Run the CI/CD

1.  **Commit a Change:** Make a minor change to your `index.html` file (or any file) in your Azure Repos project.
2.  **Push to `main`:** Commit and push these changes to the `main` branch.
3.  **Monitor Pipeline:** Navigate to **Pipelines** > **Pipelines** in Azure DevOps. You will see a new run automatically triggered by your push.
4.  **Verify Deployment:** Once the pipeline completes successfully, open your Azure App Service URL in a web browser. You should see your updated `index.html` page with the new content and cool animations!

---

## Files in this Repository

* `azure-pipelines.yml`: The YAML definition for the CI/CD pipeline.
* `index.html`: The simple, colorful HTML web application page (formerly `hellodevops.html`).

---

## Future Enhancements

* Add comprehensive unit and integration tests in the `BuildAndTest` stage.
* Implement deployment slots in Azure App Service for zero-downtime deployments.
* Integrate with a more robust monitoring solution like Application Insights.
* Expand the web application to include backend logic and database integration.
* Explore more advanced Azure DevOps features, such as environments, approvals, and security scanning.

---

## Conclusion

This project serves as a foundational demonstration of leveraging Azure Repos and Azure App Services to establish an efficient and automated CI/CD pipeline. It highlights the benefits of PaaS, automation, and continuous delivery in modern software development, showcasing a practical application of core DevOps principles.

---
