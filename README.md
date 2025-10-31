# System-Administration-Powershell
This problem outlines a practical hands-on project to gain experience in developing System Administration Automation using PowerShell. By working through this project, you will gain real-world exposure to System Monitoring, Log analysis, Report generation, PowerShell automation, cloud deployment, and infrastructure monitoring practices



- Install DotNet 
```
winget install Microsoft.DotNet.Runtime.9
```

- Connect Vm 
```
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts * -Force
```

Install Chochlety 
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

```
Enable-PSRemoting -Force
New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My | Out-Null
$thumb = (Get-ChildItem Cert:\LocalMachine\My | Sort-Object NotBefore -Descending | Select-Object -First 1).Thumbprint
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$env:COMPUTERNAME`"; CertificateThumbprint=`"$thumb`"}"
Restart-Service WinRM
```

```
 Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
 ```

 ```
 Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Vm1" -Force
 ```

 ```
 Restart-Service WinRM
 ```

 ```
 New-PSSession -ComputerName Vm1 -Credential (Get-Credential)
 ```


# Create a remote session
$session = New-PSSession -ComputerName Vm1 -Credential (Get-Credential)

# Define source and destination
$remotePath = "C:\Assignment_1\*"    # all files and folders inside Assignment_1
$localPath  = "C:\report\Vm1_Assignment_1"  # include VM name to avoid conflicts

# Make sure local folder exists
if (-not (Test-Path $localPath)) {
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Copy all files and subfolders from remote to local
Copy-Item -FromSession $session -Path $remotePath -Destination $localPath -Recurse -Force

# Verify copied files
Get-ChildItem -Path $localPath -Recurse



```
 Copy-Item -FromSession $session -Path "C:\Assignment_1" -Destination "C:\report" -Recurse -Force -Verbose
 ```
