# Automated VM Report Collection with PowerShell

## Overview

This PowerShell project automates the collection of system reports from a remote virtual machine (VM), compresses them into a timestamped ZIP file, and securely transfers the file to a central monitoring VM. It uses **PowerShell SecretManagement** to securely store credentials, allowing fully automated execution without manual intervention. Perfect for scheduled tasks or centralized monitoring setups.

---

## Description

The script collects key system information including:

- User and hostname info (`whoami`, `hostname`)
- Computer system information (`Get-ComputerInfo`)
- Network configuration (`ipconfig`)
- Services and running services
- Processes (`Get-Process`)
- Disk information (`Get-Disk`)
- Failed security events
- Escalation logic if a service fails to start after 3 attempts

After collecting this data, the script compresses it into a ZIP file named dynamically with the hostname and timestamp. The ZIP file is then copied to a monitoring VM using stored credentials, avoiding repeated manual input.

This solution is suitable for:

- System administrators monitoring multiple VMs
- Automated report generation and collection
- Secure, non-interactive credential usage for PowerShell remoting

---

## Features

- Collects comprehensive system reports
- Automatically compresses reports into timestamped ZIP files
- Escalates services that fail to start after multiple retries
- Securely stores credentials using PowerShell SecretManagement
- Supports automated execution through Task Scheduler
- Works across multiple VMs with remote PowerShell sessions

---

## Prerequisites

- PowerShell 7.x or Windows PowerShell 5.1+
- Remote PowerShell enabled on the target VM (`Enable-PSRemoting`)
- Network connectivity and permissions for WinRM
- Required modules:

```powershell
  Install-Module Microsoft.PowerShell.SecretManagement -Force -AllowClobber
  Install-Module Microsoft.PowerShell.SecretStore -Force
```

## Services you can install in your VM for monitoring 

- Install Chochlety: Package used foe installation  
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
```
choco install mysql -y
```

```
choco install vscode
```

```
choco install python -y
```

```
choco install terraform -y
```

## Workflow Diagram 

[Click here for architectural diagram](https://github.com/Tanisha-221/System-Administration-Powershell/blob/main/Workflow-Diagram.png)  
**Note** : In this project Monitoring VM copies the Zip folder, so it is single directional if you wnt bidirectional (both server copies folder) then youll have to execute the scripts of secret.ps1 and monitoring-script.ps1 on both the server to make it bidirectional. 

## Script Reference Paths https
1. [VM Creation Script](https://github.com/Tanisha-221/System-Administration-Powershell/blob/main/scripts/1-Vm-Script.ps1)
2. [Store Credentials using SecretManagement](https://github.com/Tanisha-221/System-Administration-Powershell/blob/main/scripts/3-SecretScript.ps1)
3. [Monitoring and report Collection Script](https://github.com/Tanisha-221/System-Administration-Powershell/blob/main/scripts/4-Monitoring-Script.ps1)
4. [Connection Script](https://github.com/Tanisha-221/System-Administration-Powershell/tree/main/scripts)

## Points to keep in mind :

By working on this project, you will learn:
- **PowerShell Remoting & WinRM:** Configuring remote sessions and transferring files securely.

- **PowerShell SecretManagement:** Storing and retrieving credentials securely for automation.

- **Automation with Task Scheduler:** Running scripts non-interactively.

- **System Administration Scripts:** Collecting logs, system info, and service monitoring.

- **Error Handling & Escalation Logic:** Implementing retry logic for failed services.

## Summary 

- Always validate and test remote PowerShell sessions before automation.
- Using SecretManagement avoids hardcoding sensitive credentials in scripts.
- Dynamic ZIP file names simplify automation and prevent overwriting reports.
- Proper error handling is critical when dealing with multiple services.
- Task Scheduler requires elevated privileges to execute scripts that interact with system settings.

## Future Scope/Expamsion of the project 

1. **Splunk Integration - Data Centralization and visualization**  
    - **Goal** : Send collected system metrics, logs, and reports directly to Splunk instead of (or in addition to) saving them as ZIPs.  
2. **Alerting & Automated Remediation**
    - Define thresholds (e.g., Disk usage > 90%, CPU > 85%, Service stopped).
       * PowerShell script triggers:
       * Splunk alert → Email / Teams / Slack notification
       * or an auto-remediation script (restart service, clear logs, etc.)

3. **Extend Data Collection Scope**
  * Hardware metrics: Temperature, fan speed, battery (for laptops)
  * Application logs: IIS, SQL Server, custom application events
  * Network metrics: Ping latency, bandwidth, open ports
  * Security info: Audit logs, login failures, privilege changes
  * All of these can feed into Splunk for correlation and root cause analysis.