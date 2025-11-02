# Set Variables 
$resourceGroup = "T-ResourceGroup"
$location = "westeurope"
$VNetName = "MyVnet"
$SubnetName = "MySubnet"
$NSGName = "MyNSG"
$VMNames = @("MonitoringVM", "Vm1")

# Creating 4 VMs
foreach ($vmName in $VMNames) { 
    # Create the VM
    Write-Host "Creating VM: $vmName..."
    
    # Ensure the VM name is unique for the public IP
    $publicIpName = "$vmName-pip"
    
    # Create the VM with specific configurations
    New-AzVm -ResourceGroupName $resourceGroup `
             -Name $vmName `
             -Location $location `
             -Image 'Win2022AzureEdition' `
             -VirtualNetworkName $VNetName `
             -SubnetName $SubnetName `
             -SecurityGroupName $NSGName `
             -PublicIpAddressName $publicIpName `
             -OpenPorts 5986,3389

# Wait for 30 seconds to ensure VM creation completes
Write-Host "VMs creation completed." -ForegroundColor Blue

# Custom Script to enable WinRM HTTPS and create self-signed certificate
    $script = @"
Enable-PSRemoting -Force
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value \$true
New-SelfSignedCertificate -DnsName \$env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My | Out-Null
\$thumb = (Get-ChildItem Cert:\LocalMachine\My | Sort-Object NotBefore -Descending | Select-Object -First 1).Thumbprint
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"\$env:COMPUTERNAME`"; CertificateThumbprint=`"\$thumb`"}"
Restart-Service WinRM
"@

    # Run the script inside the VM using Custom Script Extension
    Set-AzVMExtension -ResourceGroupName $resourceGroup `
        -VMName $vmName `
        -Name "EnableWinRMHTTPS" `
        -Publisher "Microsoft.Compute" `
        -ExtensionType "CustomScriptExtension" `
        -TypeHandlerVersion "1.10" `
        -SettingString ("{ `"commandToExecute`": `"powershell -ExecutionPolicy Bypass -Command `$script`" }")
}

Write-Host "VMs created and WinRM HTTPS enabled. Wait a few minutes for the setup to complete." 