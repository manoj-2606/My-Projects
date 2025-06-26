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

.
├── src/                          # Java source code directory
│   └── main/
│       └── java/
│           └── com/
│               └── example/
│                   └── myapp/
│                       └── HelloWorld.java
├── pom.xml                       # Maven project configuration file
├── azure-pipelines.yml           # Azure Pipelines YAML definition for CI
└── README.md                     # This file


## Pipeline (`azure-pipelines.yml`) Explained

The `azure-pipelines.yml` file in this repository defines the Continuous Integration pipeline:

1.  **`trigger: - main`**: The pipeline automatically runs whenever code changes are pushed to the `main` branch.
2.  **`name: 'JavaCI-$(Rev:r)'`**: Assigns a unique, sequential name to each pipeline run (e.g., `JavaCI-20250626.1`).
3.  **`pool: vmImage: 'ubuntu-latest'`**: Specifies that the pipeline job will run on a Microsoft-hosted Ubuntu Linux agent, which comes pre-installed with Java and Maven.
4.  **`steps:`**:
    * **`checkout: self`**: Clones the source code from the Azure Repos Git repository onto the build agent.
    * **`Maven@3` task (`Run Maven Build`):** This is the core build step. It uses Maven to:
        * Locate the `pom.xml` file.
        * Execute the `package` goal, which compiles the Java code, runs tests (if defined), and packages the application into a `.jar` file.
    * **`PublishBuildArtifacts@1` task (`Publish Build Artifacts`):** This task takes the compiled `.jar` file (which Maven places in the `target/` directory) and publishes it as a pipeline artifact named `JavaApp`. This artifact can then be downloaded or used by subsequent stages or release pipelines.
    * **`script:` (`Pipeline Completion Message`):** A simple script that prints a confirmation message to the pipeline logs, indicating the successful completion of the CI process.

## Setup & Running the Pipeline (End-to-End)

Follow these steps to set up and run this Java CI pipeline entirely from your web browser within Azure DevOps:

### Prerequisites

* An Azure DevOps Organization and Project.

### Step 1: Create Azure Repos Git Repository

1.  Log in to your Azure DevOps Organization (`https://dev.azure.com/<your-organization-name>`).
2.  Navigate to your Project.
3.  In the left sidebar, go to **Repos**.
4.  Click the dropdown next to the current repository name (or "New repository" if empty) and select **"New repository"**.
5.  Set **Repository type** to `Git`.
6.  Enter a **Repository name** (e.g., `my-simple-java-app`).
7.  Check **"Add a README"**.
8.  Click **"Create"**.

### Step 2: Add Java Source Code (`HelloWorld.java`)

1.  In your new `my-simple-java-app` repository (Files tab), click **"..." (More options)** then **"New file"**.
2.  In the "Path" field, type: `src/main/java/com/example/myapp/HelloWorld.java`
3.  Paste the following Java code:
    ```java
    // src/main/java/com/example/myapp/HelloWorld.java
    package com.example.myapp;

    public class HelloWorld {
        public static void main(String[] args) {
            System.out.println("Hello from Azure DevOps Java CI Pipeline!");
            System.out.println("This is a simple Java application.");
        }
    }
    ```
4.  Add a commit message (e.g., "Add initial Java HelloWorld app") and click **"Commit"**.

### Step 3: Add Maven Project File (`pom.xml`)

1.  Go back to the root of your `my-simple-java-app` repository (Files tab).
2.  Click **"..." (More options)** then **"New file"**.
3.  In the "Path" field, type: `pom.xml`
4.  Paste the following Maven XML content:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="[http://maven.apache.org/POM/4.0.0](http://maven.apache.org/POM/4.0.0)"
             xmlns:xsi="[http://www.w3.org/2001/XMLSchema-instance](http://www.w3.org/2001/XMLSchema-instance)"
             xsi:schemaLocation="[http://maven.apache.org/POM/4.0.0](http://maven.apache.org/POM/4.0.0) [http://maven.apache.org/xsd/maven-4.0.0.xsd](http://maven.apache.org/xsd/maven-4.0.0.xsd)">
        <modelVersion>4.0.0</modelVersion>

        <groupId>com.example.myapp</groupId>
        <artifactId>hello-java-ci</artifactId>
        <version>1.0-SNAPSHOT</version>
        <packaging>jar</packaging>

        <properties>
            <maven.compiler.source>11</maven.compiler.source>
            <maven.compiler.target>11</maven.compiler.target>
            <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        </properties>

        <build>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-jar-plugin</artifactId>
                    <version>3.2.0</version>
                    <configuration>
                        <archive>
                            <manifest>
                                <addClasspath>true</addClasspath>
                                <mainClass>com.example.myapp.HelloWorld</mainClass>
                            </manifest>
                        </archive>
                    </configuration>
                </plugin>
            </plugins>
        </build>

    </project>
    ```
5.  Add a commit message (e.g., "Add Maven pom.xml") and click **"Commit"**.

### Step 4: Add Azure Pipelines YAML (`azure-pipelines.yml`)

1.  Go back to the root of your `my-simple-java-app` repository (Files tab).
2.  Click **"..." (More options)** then **"New file"**.
3.  In the "Path" field, type: `azure-pipelines.yml`
4.  Paste the pipeline YAML content (provided in previous responses, or copy from the "Pipeline (`azure-pipelines.yml`) Explained" section above).
5.  Add a commit message (e.g., "Add Azure Pipelines YAML for Java CI") and click **"Commit"**.

### Step 5: Create and Run Azure DevOps Pipeline

1.  In your Azure DevOps Project, navigate to **Pipelines** > **Pipelines**.
2.  Click **"New pipeline"**.
3.  Select **"Azure Repos Git"** as your source.
4.  Choose your new repository (`my-simple-java-app`).
5.  When prompted to configure the pipeline, select **"Existing Azure Pipelines YAML file"**.
6.  Choose `azure-pipelines.yml` from the `main` branch.
7.  Review the YAML and click **"Save and run"**.

The pipeline will now automatically trigger based on the last commit you made when adding `azure-pipelines.yml`. You can monitor its progress in the "Runs" section of your pipeline. Upon successful completion, you will see a published artifact containing your built Java application.

---

## Future Enhancements

* **Add Unit Tests:** Implement JUnit tests in your Java project and add a `Maven@3` task with `goals: 'test'` to your pipeline.
* **Code Quality:** Integrate static analysis tools (e.g., SonarQube) into your pipeline.
* **Continuous Deployment:** Add a `Deploy` stage to automatically deploy the built `.jar` file to an Azure service (e.g., Azure App Service for Java, Azure Container Apps, or Azure Kubernetes Service). This would require setting up an Azure resource and an Azure DevOps Service Connection.
* **Containerization:** Dockerize your Java application and push the image to Azure Container Registry.

---
