# Install and import modules
Install-Module -Name Microsoft.PowerShell.SecretManagement -Force -AllowClobber
Install-Module -Name Microsoft.PowerShell.SecretStore -Force
Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

# Register SecretStore as default vault
Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

# Configure SecretStore for non-interactive automation
Set-SecretStoreConfiguration -Authentication None -Interaction None -Confirm:$false

# Store credentials interactively (run once)
$cred = Get-Credential -Message "Enter username and password for VM1"
Set-Secret -Name "Vm1Cred" -Secret $cred