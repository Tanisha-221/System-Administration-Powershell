# Import modules if needed
Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

# Retrieve stored credential
$Vm1Cred = Get-Secret -Name "Vm1Cred"

# Enable remoting and allow trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Restart-Service WinRM -Force

# Create a remote session using stored credential
$session = New-PSSession -ComputerName Vm1 -Credential $Vm1Cred

# Generate dynamic zip filename (matches your earlier report script)
$remoteZipFile = "C:\AllReports*.zip"

# Copy the file from remote VM to local monitoring VM
Copy-Item -FromSession $session -Path $remoteZipFile -Destination "C:\" -Recurse -Force -Verbose

# Clean up session
Remove-PSSession $session

Write-Host "File copied successfully from VM1 to monitoring VM."