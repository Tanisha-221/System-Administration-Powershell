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
```
+------------------------+        +------------------------+
|    Remote VM (VM1)     |        |  Monitoring VM (VM2)   |
|------------------------|        |------------------------|
| 1. Collect system info |        |                        |
| 2. Generate report txt |        |                        |
| 3. Compress to ZIP     |        |                        |
| 4. Store ZIP locally   |        |                        |
+------------------------+        |                        |
          | Copy ZIP via PSSession |                        |
          +----------------------->|  Receive ZIP file      |
                                     |  Store locally         |
                                     +------------------------+

```

## Script Reference Paths 
1. [VM Creation Script](https://github.com/Tanisha-221/System-Administration-Powershell/blob/main/Vm-Script)
2. [Store Credentials using SecretManagement]()
3. [Monitoring and report Collection Script]()
4. [Connection Script]()

## Laerning Objective:

By working on this project, you will learn:
- **PowerShell Remoting & WinRM:** Configuring remote sessions and transferring files securely.

- **PowerShell SecretManagement:** Storing and retrieving credentials securely for automation.

- **Automation with Task Scheduler:** Running scripts non-interactively.

- **System Administration Scripts:** Collecting logs, system info, and service monitoring.

- **Error Handling & Escalation Logic:** Implementing retry logic for failed services.

## Lessons Learned

- Always validate and test remote PowerShell sessions before automation.
- Using SecretManagement avoids hardcoding sensitive credentials in scripts.
- Dynamic ZIP file names simplify automation and prevent overwriting reports.
- Proper error handling is critical when dealing with multiple services.
- Task Scheduler requires elevated privileges to execute scripts that interact with system settings.