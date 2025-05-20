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
