# Project: Azure VM Backup and Restore Simulation

This project demonstrates the fundamental concepts and practical steps involved in protecting Azure Virtual Machines (VMs) using Azure Backup and Recovery Services Vaults. It covers configuring a backup policy, triggering manual backups, and understanding the restore process.

## Project Goal

To gain hands-on experience with Azure VM backup, emphasizing data protection and the ability to recover VMs from specific points in time.

## Architecture & Components

The solution utilizes the following Azure resources:

-   **Resource Group:** (`MonarchBackupRG`) - A logical container for all project-related Azure resources.
-   **Virtual Machine (VM):** (`MonarchBackupVM`) - A Linux VM that serves as the resource whose data will be backed up.
-   **Recovery Services Vault (RSV):** (`MonarchRecoveryVault`) - A centralized management entity in Azure for managing backup and disaster recovery. It acts as the destination for your VM backups.
-   **Backup Policy:** Defines the schedule (e.g., daily) and retention rules for your VM backups.
-   **Backup Item:** Represents the specific VM being protected within the Recovery Services Vault.
-   **Restore Point:** A time-stamped copy of your VM's data, stored in the RSV, which can be used to recover the VM to a previous state.

+----------------+       +-----------------------+       +-------------------+
|  Azure VM      |       |  Recovery Services    |       |  Azure Backup     |
| (MonarchBackupVM)| <---> |  Vault (MonarchRecoveryVault) | <---> |  Storage (Managed by Azure) |
+----------------+       +-----------------------+       +-------------------+
^                           ^
|                           | Configures / Triggers
| Backs up data             | Backups
v                           v
+-----------------------+       +----------------+
|  Backup Policy        |       | Backup Jobs    |
| (DailyVMBackupPolicy) |       | (Monitor Progress) |
+-----------------------+       +----------------+


## Learning Objectives

Upon completing this project, you will understand:

* The role and importance of a **Recovery Services Vault** for centralized backup management.
* How to **configure a backup policy** for Azure VMs.
* The process of **triggering manual VM backups**.
* The concept of **restore points** and how they enable data recovery.
* The different **restore options** available for Azure VMs (creating new, restoring disks, replacing existing).
* **Cost Management:** Awareness of prompt resource deletion after practice.

## Prerequisites

* An active Azure subscription.

---

## Project Steps: A Complete Walkthrough

Follow these steps to deploy and configure the VM backup solution in your Azure subscription.

### Phase 1: Foundation Setup - Create Resource Group & Virtual Machine

1.  **Create a Resource Group:**
    * Navigate to "Resource groups" in the Azure Portal.
    * Click `+ Create`.
    * **Resource group name:** `MonarchBackupRG`.
    * **Region:** `Central India` (ensure consistency for all resources).
    * Click `Review + create` then `Create`.

2.  **Deploy a Linux Virtual Machine:**
    * Navigate to "Virtual machines" in the Azure Portal.
    * Click `+ Create` > `Azure virtual machine`.
    * **Basics tab:**
        * **Resource group:** Select `MonarchBackupRG`.
        * **Virtual machine name:** `MonarchBackupVM`.
        * **Region:** Must be the same as your Resource Group.
        * **Image:** `Ubuntu Server 24.04 LTS` (or `20.04 LTS`/`22.04 LTS`).
        * **Size:** Select a small size like `Standard B1ls` or `Standard B1s` for cost efficiency.
        * **Administrator account:** Set up `Password` (remember credentials!).
        * **Inbound port rules:** Select `None`.
    * **Management tab:**
        * **OS guest diagnostics:** Ensure this is `Disabled`. (To avoid deployment issues).
        * **Auto-shutdown:** **Enable** and configure for cost savings.
    * Click `Review + create` then `Create`.
    * **Wait for the `MonarchBackupVM` deployment to complete successfully.**

### Phase 2: Create a Recovery Services Vault (RSV)

1.  **Create a Recovery Services Vault:**
    * Navigate to "Recovery Services vaults" in the Azure Portal.
    * Click `+ Create`.
    * **Subscription:** Your Azure Subscription.
    * **Resource group:** Select `MonarchBackupRG`.
    * **Vault name:** `MonarchRecoveryVault`.
    * **Region:** **Must be the same as your VM (e.g., `Central India`)**.
    * Click `Review + create` then `Create`.
    * **Wait for the deployment to succeed.**

### Phase 3: Configure Backup for your VM

1.  **Configure Backup Goal:**
    * Go to `MonarchRecoveryVault` overview page.
    * In the left-hand menu, under "Getting started," click **"Backup."**
    * **Where is your workload running?**: `Azure`.
    * **What do you want to back up?**: `Virtual machine`.
    * Click **`Backup`**.

2.  **Create a Backup Policy:**
    * **Backup policy:** Select `Create new policy`.
    * **Policy name:** `DailyVMBackupPolicy`.
    * **Schedule:** Set `Frequency` to `Daily` and choose a `Time`.
    * **Retention:** Keep defaults.
    * Click **`OK`**.

3.  **Select Virtual Machines to Back Up:**
    * On the "Virtual machines" section, click **`+ Add Virtual machines`**.
    * Select the checkbox next to your **`MonarchBackupVM`**.
    * Click **`OK`**.

4.  **Enable Backup:**
    * Click the blue **`Enable backup`** button.
    * This associates your VM with the policy.

### Phase 4: Trigger a Manual Backup

1.  **Navigate to Backup Items:**
    * Go to `MonarchRecoveryVault` overview page.
    * In the left menu, under "Protected items," click **"Backup items."**
    * Select `Azure Virtual Machine` from the dropdown.

2.  **Initiate Backup Now:**
    * Click on your `MonarchBackupVM` from the list.
    * Click the **`Backup now`** button.
    * Keep the default "Retain Backup till" date and click **`OK`**.
    * **Monitor progress:** View the job status under "Backup jobs" in the RSV left menu. Wait for it to show **"Completed"**.

### Phase 5: Simulate a Restore Point (Do NOT actually restore)

Once the manual backup is "Completed":

1.  **Access Restore Options:**
    * Go to `MonarchRecoveryVault` overview page > "Backup items" > `Azure Virtual Machine`.
    * Click on your `MonarchBackupVM`.
    * Click the **`Restore VM`** button.

2.  **Simulate Restore:**
    * On the "Restore" blade, observe the available "Restore point" options (select the most recent one).
    * Observe the "Restore type" options (e.g., `Create new`, `Restore disks`, `Replace existing`).
    * **Crucially: Do NOT click through "Next" or "Restore."** The goal is to confirm the presence of restore points and understand the options.
    * Close the blade by clicking the `X` in the top right corner.

---

## Troubleshooting Notes

* **Region Mismatch:** Ensure all resources (Resource Group, VM, Recovery Services Vault) are created in the **exact same Azure region**. Mismatches can cause backup configuration failures.
* **OS Guest Diagnostics:** If deploying Ubuntu 24.04 (or other Linux versions), explicitly **disable "OS guest diagnostics"** during VM creation to avoid conflicts with older diagnostic extensions that might not support newer OS versions.
* **Backup Job Progress:** Initial backups can take time (10-30+ minutes). Be patient and monitor the "Backup jobs" section in the Recovery Services Vault.

## Cleanup

To avoid ongoing charges, always delete the Resource Group which will remove all associated resources.

1.  Navigate to "Resource groups" in the Azure Portal.
2.  Select the checkbox next to `MonarchBackupRG`.
3.  Click `Delete resource group`.
4.  Type the resource group name (`MonarchBackupRG`) to confirm, then click `Delete`.

---
