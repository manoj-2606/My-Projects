# Simple Java CI Pipeline with Azure DevOps (Azure Repos Source)

This repository demonstrates a foundational Continuous Integration (CI) pipeline for a basic Java application. The entire setup, from source code management to pipeline definition, is orchestrated within **Azure DevOps**, using an **Azure Repos Git repository** as the code source.

This project highlights how to:
* Manage Java source code directly within Azure Repos.
* Define a CI pipeline using YAML in Azure Pipelines.
* Automatically build a Java application using Maven on Microsoft-hosted agents.

---

## Table of Contents

* [Project Goal](#project-goal)
* [Application Overview](#application-overview)
* [Architecture Flow](#architecture-flow)
* [Azure Components Used](#azure-components-used)
* [Repository Structure](#repository-structure)
* [Pipeline (`azure-pipelines.yml`) Explained](#pipeline-azure-pipelinesyml-explained)
* [Setup & Running the Pipeline (End-to-End)](#setup--running-the-pipeline-end-to-end)
    * [Prerequisites](#prerequisites)
    * [Step 1: Create Azure Repos Git Repository](#step-1-create-azure-repos-git-repository)
    * [Step 2: Add Java Source Code (`HelloWorld.java`)](#step-2-add-java-source-code-helloworldjava)
    * [Step 3: Add Maven Project File (`pom.xml`)](#step-3-add-maven-project-file-pomxml)
    * [Step 4: Add Azure Pipelines YAML (`azure-pipelines.yml`)](#step-4-add-azure-pipelines-yaml-azure-pipelinesyml)
    * [Step 5: Create and Run Azure DevOps Pipeline](#step-5-create-and-run-azure-devops-pipeline)
* [Future Enhancements](#future-enhancements)

---

## Project Goal

The primary goal of this project is to implement a fully functional Continuous Integration (CI) pipeline for a simple Java application. This pipeline automatically fetches code from Azure Repos, builds it using Maven, and publishes the resulting artifacts.

## Application Overview

The application is a minimalistic Java "Hello World" program (`HelloWorld.java`). It's structured as a standard Maven project to demonstrate a typical Java build process within a CI pipeline.

* `src/main/java/com/example/myapp/HelloWorld.java`: The main Java source file.
* `pom.xml`: The Maven project object model file, defining how the Java application is built.

## Architecture Flow

The CI process for this project follows this flow:

`Azure Repos (Code Source)` &rarr; `Azure Pipelines (Build Automation)`

* **Continuous Integration (CI):** Any push to the `main` branch in the Azure Repos repository automatically triggers the Azure Pipeline to build the Java application.

## Azure Components Used

* **Azure Repos:** Used for hosting the Git source code repository.
* **Azure Pipelines:** Used for defining and executing the CI workflow (fetching code, Maven build, artifact publishing).

## Repository Structure
