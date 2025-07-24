# Azure VM Monitoring with Azure Monitor Agent (AMA) and Log Analytics

## Project Overview

This project demonstrates how to set up basic monitoring for an Azure Linux Virtual Machine (VM) using **Azure Monitor Agent (AMA)** and **Azure Log Analytics Workspace**. The goal is to collect essential performance metrics and system logs from the VM, centralize them, and enable querying for operational insights. This setup forms the foundation for more advanced monitoring, alerting, and troubleshooting in Azure.

## Why This Project?

In a cloud environment, understanding the health and performance of your virtual machines is crucial. Azure Monitor provides a comprehensive solution for this, allowing you to:
* **Centralize Data:** Collect logs and metrics from various sources into a single Log Analytics Workspace.
* **Gain Insights:** Use Kusto Query Language (KQL) to analyze collected data for performance bottlenecks, errors, and security events.
* **Proactive Monitoring:** Set up alerts to notify you of critical conditions (e.g., high CPU usage, low disk space).
* **Troubleshooting:** Quickly diagnose issues by examining detailed logs and metrics.

## How It Works

The project follows a logical flow to establish the monitoring pipeline:

1.  **Resource Group Creation:** All resources for this project are contained within a dedicated Azure Resource Group (e.g., `MonarchCustomLogRG`). This provides a clean way to manage and de-provision all associated components.
2.  **Log Analytics Workspace (LAW) Creation:** A Log Analytics Workspace (e.g., `MonarchCustomLogLAW3`) is created. This acts as the central data store for all logs and metrics collected from the monitored VM.
3.  **Virtual Machine (VM) Deployment:** A Linux Virtual Machine (e.g., `MonarchCustomLogVM` running Ubuntu 24.04) is deployed. This is the resource that will be monitored. Crucially, during VM creation, "OS guest diagnostics" are explicitly *disabled* to avoid conflicts with AMA.
4.  **Data Collection Endpoint (DCE) Creation:** A Data Collection Endpoint (e.g., `MonarchCustomLogDCE`) is created in the *same region* as the Log Analytics Workspace and VM. This endpoint is necessary for the Azure Monitor Agent to securely send data to the LAW.
5.  **Azure Monitor Agent (AMA) Deployment & DCR Association:** The Azure Monitor Agent (AMA) is installed on the VM, and a Data Collection Rule (DCR) is automatically associated with it. This DCR (e.g., `ms-linux-MonarchCustomLogVM-<GUID>`) defines:
    * **What data to collect:** Standard Linux performance counters (CPU, memory, disk) and Syslog events.
    * **Where to send it:** To the specified Log Analytics Workspace (`MonarchCustomLogLAW3`).
    * This is often configured directly from the VM's "Logs" blade in the Azure portal.
6.  **Log Querying with KQL:** Once data starts flowing, you can navigate to the Log Analytics Workspace and use Kusto Query Language (KQL) to query the collected data (e.g., `Heartbeat`, `Perf`, `Syslog` tables). This allows for deep analysis and visualization.
7.  **Alerting (Optional but Recommended):** Alert rules can be configured based on the collected metrics (e.g., "Alert me if CPU usage on `MonarchCustomLogVM` exceeds 70% for 5 minutes").

## Common Issues Faced During This Project

This project highlighted several critical, often subtle, issues that can arise when setting up Azure Monitor:

1.  **"Table does not exist" Error for Custom Logs:**
    * **Problem:** Persistent errors indicating `MyAppLogs_CL` table was not found when configuring the DCR for custom text logs. This occurred despite attempts to pre-create the table using `datatable` with `consume` or `make-series` KQL queries, and even through the "New custom log (DCR-based)" UI wizard.
    * **Resolution (Partial):** Due to the intractability of this specific issue, the project scope was adjusted to focus on standard performance counters and Syslog, as these tables are automatically managed by Azure Monitor. The custom log feature, while theoretically possible, proved too complex for a seamless demonstration in this specific environment.

2.  **Kusto Query Language (KQL) Parsing Errors:**
    * **Problem:** KQL queries intended to create custom table schemas repeatedly failed with parsing errors (e.g., "Query could not be parsed at ')'" or "Query could not be parsed at 'string'"). This indicated very sensitive syntax handling by the Log Analytics query editor in this environment.
    * **Resolution:** Simplified KQL was attempted, and ultimately, the direct table creation was abandoned in favor of relying on default tables.

3.  **"No data collection endpoints found" Error:**
    * **Problem:** When attempting to create a DCR, the portal reported no available Data Collection Endpoints (DCEs) in the region, preventing DCR creation. The "Data collection endpoints" blade also showed no DCEs to display.
    * **Resolution:** The DCE (e.g., `MonarchCustomLogDCE`) had to be explicitly created in the correct region (`Central India`) and its successful deployment confirmed before it became selectable for DCR creation.

4.  **Cross-Region Data Collection Rule (DCR) Conflicts:**
    * **Problem:** An existing, automatically created DCR (e.g., `MSVMI-DefaultWorkspace-...`) was located in an incorrect region (e.g., "East US") while all other resources (VM, LAW) were in "Central India". This regional mismatch likely prevented the Azure Monitor Agent from correctly linking and sending data, leading to "No results found" for `Heartbeat` queries.
    * **Resolution:** The problematic cross-region DCR was identified as a critical blocking issue and had to be deleted. A new, correctly-regionalized DCR then needed to be associated with the VM.

5.  **VM "OS guest diagnostics" vs. Azure Monitor Agent (AMA) Conflicts:**
    * **Problem:** Initial VM deployments failed due to the `LinuxDiagnostic` extension when "OS guest diagnostics" were enabled during VM creation, especially with newer Ubuntu versions (e.g., 24.04 LTS). This older diagnostic extension conflicts with the modern AMA.
    * **Resolution:** The VM was re-deployed (or an existing one used) with "OS guest diagnostics" explicitly *disabled*. This allowed AMA to be deployed and managed solely by DCRs.

## Key Learnings

* **Region Consistency is Paramount:** Ensure all related Azure Monitor resources (VMs, Log Analytics Workspaces, Data Collection Endpoints, Data Collection Rules) are in the *same Azure region*.
* **Azure Monitor Agent (AMA) is Key:** For modern monitoring, especially for Linux VMs and custom logs, AMA is the agent to use, managed by DCRs. Avoid older diagnostic extensions or OMS Agent where AMA is preferred.
* **UI Workflows Can Vary:** The Azure portal UI can have multiple paths for seemingly similar tasks (e.g., creating custom logs), and finding the correct, most stable path is sometimes a challenge.
* **Troubleshooting Requires Patience:** Persistent issues often stem from subtle configuration mismatches or deployment failures. Incremental verification and systematic elimination of variables are crucial.

This project, despite its challenges, provided valuable insights into the intricacies of setting up robust monitoring in Azure, emphasizing the importance of precise configuration and understanding the interplay between different Azure Monitor components.

---
