# Azure Monitor: Linux VM Observability Project

This repository documents a hands-on project focused on setting up basic monitoring for a Linux Virtual Machine (VM) in Azure using Azure Monitor. The project demonstrates key components like Log Analytics Workspaces, Data Collection Rules, and KQL for data analysis.

## Project Goal

To establish a monitoring solution for an Azure Linux VM to collect performance metrics and system logs, store them in a centralized Log Analytics Workspace, and query the collected data.

## Architecture

The solution utilizes the following Azure resources:

-   **Resource Group:** A logical container to organize all related Azure resources.
-   **Log Analytics Workspace (LAW):** A unique environment where log data from various Azure resources is collected, indexed, and stored. It provides a powerful query language (Kusto Query Language - KQL) for data analysis.
-   **Virtual Machine (VM):** The Linux-based compute resource whose operational data (performance, system logs) will be collected.
-   **Data Collection Rule (DCR):** Defines what data needs to be collected, from which resources (VMs), and where that data should be sent (to the Log Analytics Workspace). It manages the configuration of the Azure Monitor Agent (AMA).
-   **Azure Monitor Agent (AMA):** A lightweight agent installed on the VM that collects data as defined by the DCR and sends it to the Log Analytics Workspace.

+----------------+       +-------------------+       +-----------------------+
|  Linux VM      |       |  Azure Monitor    |       |  Log Analytics        |
| (Ubuntu 24.04) | <---> |  Agent (AMA)      | <---> |  Workspace            |
|                |       |  (DCR Configured) |       |  (Data Storage & KQL) |
+----------------+       +-------------------+       +-----------------------+
^
| Data Collection Rule (DCR) links VM to AMA/LAW config
| (Ensures AMA collects specified data and sends to LAW)
v
+------------------------+
| Data Collection Rule   |
| (Region: Central India)|
+------------------------+


## Setup Steps (Azure Portal Only)

Follow these steps to deploy and configure the monitoring solution in your Azure subscription.

### Phase 1: Foundation Setup

1.  **Create a Resource Group:**
    * Navigate to "Resource groups" in the Azure Portal.
    * Click `+ Create`.
    * **Subscription:** Your Azure Subscription.
    * **Resource group name:** `MonarchMonitorRG` (or a similar descriptive name).
    * **Region:** `Central India` (or your preferred region, ensure consistency for all resources).
    * Click `Review + create` then `Create`.

2.  **Create a Log Analytics Workspace:**
    * Navigate to "Log Analytics workspaces" in the Azure Portal.
    * Click `+ Create`.
    * **Subscription:** Your Azure Subscription.
    * **Resource group:** Select `MonarchMonitorRG`.
    * **Name:** `MonarchMonitorLAW` (or a similar descriptive name).
    * **Region:** **Must be the same as your Resource Group (e.g., `Central India`)**.
    * **Pricing tier:** Choose "Free tier" (if available) or "Pay-as-you-go".
    * Click `Review + create` then `Create`.

3.  **Deploy a Linux Virtual Machine:**
    * Navigate to "Virtual machines" in the Azure Portal.
    * Click `+ Create` > `Azure virtual machine`.
    * **Basics tab:**
        * **Subscription:** Your Azure Subscription.
        * **Resource group:** Select `MonarchMonitorRG`.
        * **Virtual machine name:** `MonarchMonitorVM`.
        * **Region:** **Must be the same as your RG and LAW (e.g., `Central India`)**.
        * **Image:** `Ubuntu Server 24.04 LTS` (or `20.04 LTS`/`22.04 LTS` if preferred).
        * **Size:** Select a small size like `Standard B1ls` or `Standard B1s` for cost efficiency.
        * **Administrator account:** Set up `SSH public key` or `Password` (remember credentials!).
        * **Inbound port rules:** Set to `None` for security.
    * **Disks tab:** Keep defaults.
    * **Networking tab:** Keep defaults.
    * **Management tab:**
        * **OS guest diagnostics:** **Ensure this is `Disabled`**. (Crucial to avoid conflicts with AMA and past issues encountered).
        * **Auto-shutdown:** **Enable** and configure for cost savings (e.g., daily shutdown time).
    * Click through remaining tabs (`Monitoring`, `Advanced`, `Tags`) and click `Review + create` then `Create`.
    * Wait for the VM deployment to complete successfully.

### Phase 2: Configure Azure Monitor Agent (AMA) and Data Collection

1.  **Configure Log Collection for the VM (Installs AMA and associates a DCR):**
    * Navigate to your `MonarchMonitorVM` in the Azure Portal.
    * In the left-hand menu, under "Monitoring," click on **"Logs."**
    * You should see an option to "Configure Log Collection" or "Enable Azure Monitor for VMs". Click this option.
    * On the configuration blade:
        * **Subscription:** Confirm your subscription.
        * **Log Analytics workspace:** Select your `MonarchMonitorLAW`.
        * The system will automatically create a *new* Data Collection Rule (DCR) or associate an existing one if available in the *correct region*.
            * **Crucially, ensure the "Region" specified for the DCR (if a new one is being created) is `Central India`.**
    * Click **`Configure`** or **`Enable`**.
    * This process will deploy the Azure Monitor Agent (AMA) to your VM and associate it with a DCR that collects basic Linux performance counters and Syslog data.

2.  **Verify the automatically created DCR:**
    * In the Azure Portal search bar, type `Data collection rules` and select it.
    * You should now see a new DCR with a name pattern like `ms-linux-<VM_Name>-<GUID>` (e.g., `ms-linux-MonarchMonitorVM-a1b2c3d4-e5f6-7890-1234-567890abcdef`).
    * Click on this DCR.
    * In the left menu, go to **"Resources"** and confirm `MonarchMonitorVM` is listed.
    * In the left menu, go to **"Data sources"** and confirm "Linux Performance Counters" and "Linux Syslog" are listed.

### Phase 3: Querying Logs in Log Analytics

Allow at least **5-10 minutes** after AMA installation and DCR association for data to start flowing.

1.  **Access Log Analytics Workspace:**
    * Navigate to your `MonarchMonitorLAW` in the Azure Portal.
    * In the left menu, under "General," click **"Logs."**

2.  **Run KQL Queries:**
    * **Check Heartbeat (confirm AMA is active):**
        ```kusto
        Heartbeat
        | where Computer == "MonarchMonitorVM"
        | summarize LastHeartbeat = max(TimeGenerated) by Computer
        | project Computer, LastHeartbeat
        ```
        * Set "Time range" to "Last 30 minutes" or "Last 1 hour". You should see your VM's last heartbeat time.
    * **View VM Performance Data (e.g., CPU Usage):**
        ```kusto
        Perf
        | where Computer == "MonarchMonitorVM"
        | where ObjectName == "Processor" and CounterName == "% Processor Time"
        | summarize avgCpu = avg(CounterValue) by bin(TimeGenerated, 5m)
        | render timechart title="Average CPU Usage for MonarchMonitorVM"
        ```
        * Set "Time range" to "Last 4 hours".
    * **View Linux Syslog Data:**
        ```kusto
        Syslog
        | where Computer == "MonarchMonitorVM"
        | order by TimeGenerated desc
        | take 50
        ```
        * Set "Time range" to "Last 4 hours".

### Phase 4: Basic Alerting (Optional but Recommended)

1.  **Create an Action Group (for notifications):**
    * In the Azure Portal search bar, type `Action groups` and select it.
    * Click `+ Create`.
    * **Basics tab:**
        * **Subscription:** Your Azure Subscription.
        * **Resource group:** `MonarchMonitorRG`.
        * **Action group name:** `MonarchAlertsAG`.
        * **Short name:** `MonarchAG`.
    * **Notifications tab:**
        * **Notification type:** `Email/SMS message/Push/Voice`.
        * **Name:** `EmailMe`.
        * **Email:** Enter your email address.
    * Click `Review + create` then `Create`.

2.  **Create an Alert Rule for High CPU Usage:**
    * Navigate to your `MonarchMonitorVM` in the Azure Portal.
    * In the left-hand menu, under "Monitoring," click **"Alerts."**
    * Click `+ Create alert rule`.
    * **Scope:** Your `MonarchMonitorVM` should be pre-selected.
    * **Condition:**
        * Click `Add condition`.
        * **Signal type:** `Metrics`.
        * **Monitor Service:** `Virtual Machine Host`.
        * **Signal name:** Search for and select `CPU usage`.
        * **Threshold:** `Static`.
        * **Operator:** `Greater than`.
        * **Threshold value:** `70` (for 70% CPU usage).
        * **Aggregation granularity (Period):** `5 minutes`.
        * **Frequency of evaluation:** `5 minutes`.
        * Click `Done`.
    * **Actions:**
        * Click `Select action groups`.
        * Select the checkbox for `MonarchAlertsAG`.
        * Click `Select`.
    * **Details tab:**
        * **Alert rule name:** `MonarchVM-HighCPU-Alert`.
        * **Severity:** `Sev 3 (Warning)`.
    * Click `Review + create` then `Create`.

## Cleanup

To avoid ongoing charges, remember to delete the Resource Group which will remove all associated resources.

1.  Navigate to "Resource groups" in the Azure Portal.
2.  Select the checkbox next to `MonarchMonitorRG`.
3.  Click `Delete resource group`.
4.  Type the resource group name (`MonarchMonitorRG`) to confirm, then click `Delete`.
