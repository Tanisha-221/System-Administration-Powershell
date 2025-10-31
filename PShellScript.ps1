$startTime = Get-Date
Write-Host "Script started at $startTime"

# Define folder path 
$folder = "C:\Assignment_1"

if (-not (Test-Path $folder)) {
    Write-Host "Creating folder"
    New-Item -Path $folder -ItemType Directory | Out-Null
} else {
    Write-Host "Folder exists"
}

# ------ 1. Whoami -----------------
whoami | Out-File -Filepath "$folder\whoami.txt" -Append

# ------ 2. hostname --------------
hostname | Out-File -FilePath "$folder\hostname.txt" -Append

# ------ 3. Computer Info-----------
Get-ComputerInfo |Out-File -FilePath "$folder\ComputerInfo.txt" -Append

# ------ 4. IP Configuration ----------
ipconfig | Out-File -FilePath "$folder\IpConfig.txt" -Append

# ------ 5. List all services -----------
Get-Service | Out-File -FilePath "$folder\Services.txt" -Append

# ------ 6. List running services ------
Get-Service | Where-Object {$_.Status -eq "Running"} | Out-File -FilePath "$folder\RunningServices.txt" -Append

# ------ 7. System Info ------------
SystemInfo | Out-File -FilePath "$folder/SystemInfo.txt" -Append

# ------ 8. Processes ------------
Get-Process | Out-File -FilePath "$folder\Processes.txt" -Append

# ------ 9. Disk Information ---------
Get-Disk | Out-File -FilePath "$folder\DiskInfo.txt" -Append

# ------10. Escalation if service fails to start on 3 cosecutive checks -------
$failedServices = @()

        foreach ($service in Get-Service | Where-Object { $_.StartType -ne 'Disabled' }) {
            $retryCount = 0
            $maxRetries = 3
            $serviceStarted = $false

            while ($retryCount -lt $maxRetries -and !$serviceStarted) {
                Write-Output "Starting service '$($service.Name)' (Attempt $($retryCount + 1) of $maxRetries)..."
                try {
                    Start-Service -Name $service.Name -ErrorAction Stop
                    Write-Output "Service '$($service.Name)' started successfully on attempt $($retryCount + 1)."
                    $serviceStarted = $true
                }
                catch {
                    Write-Output "Failed to start service '$($service.Name)' on attempt $($retryCount + 1)."
                    $retryCount++
                    Start-Sleep -Seconds 5
                }
            }

            if (!$serviceStarted) {
                $failedServices += $service.Name
                Write-Output "Escalation: Service '$($service.Name)' failed to start after $maxRetries attempts."
            }
        }

        if ($failedServices.Count -gt 0) {
            $failedServices | Out-File -FilePath "$folder\failed-services.txt"
            Write-Output "Escalation completed. Failed services are logged in '$folder\failed-services.txt'."
        }
        else {
            Write-Output "All services started successfully or already running."
        }

# -------- 11fol. Failed login ----------
$securityFile = "$folder\FailedSecurityEvents.txt"

try {
    Get-WinEvent -LogName Security | 
        Where-Object { $_.LevelDisplayName -eq "Failure Audit" } |
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Out-File -FilePath $securityFile -Force

    Write-Host " Failed security events saved to $securityFile"
}
catch {
    Write-Host " Failed to retrieve security events: $_"
}

# -------- Zip the folder -------------
$hostName = $env:COMPUTERNAME
$zipFile = "C:\AllReports_${hostName}_$(Get-Date -Format 'yyyyMMdd_HHmm').zip"

# Check if folder has any files before compressing
if (Test-Path $folder) {
    $items = Get-ChildItem -Path $folder -Recurse -File -Exclude *.zip
    if ($items.Count -gt 0) {
        Compress-Archive -Path $folder\* -DestinationPath $zipFile -Force
        Write-Host "All reports archived at $zipFile"
    }else{
        Write-Host "No files found in $folder to archive."
    }
}else{
    Write-Host "Folder $folder does not exist — nothing to archive."
}

# --------- Script End Time ------------
$endTime = Get-Date
Write-Host "Script completed at $endTime"