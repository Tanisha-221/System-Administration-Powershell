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
try{
    whoami | Out-File -Filepath "$folder\whoami.txt" -Append
    Write-Output "Whoami command executed successfully"
}catch{
    Write-Output "Failed to execute whoami command"
}

# ------ 2. hostname --------------
try{
    hostname | Out-File -FilePath "$folder\hostname.txt" -Append
    Write-Output "Hostname command executed successfully"
}catch{
    Write-Output "Failed to execute hostname command"
}

# ------ 3. Computer Info-----------
try{
    Get-ComputerInfo |Out-File -FilePath "$folder\ComputerInfo.txt" -Append
    Write-Output "Computer Info command executed successfully"
}catch{
    Write-Output "Failed to execute Computer Info command"
}

# ------ 4. IP Configuration ----------
try{
    ipconfig | Out-File -FilePath "$folder\IpConfig.txt" -Append
    Write-Output "IP Configuration command executed successfully"
}catch{
    Write-Output "Failed to execute IP Configuration command"
}

# ------ 5. List all services -----------
try{
    Get-Service | Out-File -FilePath "$folder\Services.txt" -Append
    Write-Output "List all services command executed successfully"
}catch{
    Write-Output "Failed to execute List all services command"
}

# ------ 6. List running services ------
try{
    Get-Service | Where-Object {$_.Status -eq "Running"} | Out-File -FilePath "$folder\RunningServices.txt" -Append
    Write-Output "List running services command executed successfully"
}catch{
    Write-Output "Failed to execute List running services command"
}

# ------ 7. System Info ------------
try{
    SystemInfo | Out-File -FilePath "$folder/SystemInfo.txt" -Append
    Write-Output "System Info command executed successfully"
}catch{
    Write-Output "Failed to execute System Info command"
}

# ------ 8. Processes ------------
try{
    Get-Process | Out-File -FilePath "$folder\Processes.txt" -Append
    Write-Output "Processes command executed successfully"
}catch{
    Write-Output "Failed to execute Processes command"
}

# ------ 9. Disk Information ---------
try{
    Get-Disk | Out-File -FilePath "$folder\DiskInfo.txt" -Append
    Write-Output "Disk Information command executed successfully"
}catch{
    Write-Output "Failed to execute Disk Information command"
}

# ------10. Escalation if service fails to start on 3 cosecutive checks -------
$failedServices = @()

        foreach ($service in Get-Service | Where-Object { $_.StartType -ne 'Disabled' }) {
            Write-Output ("ForEach started at" + (Get-Date))
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
            Write-Output ("ForEach ended at" + (Get-Date))
        }

        if ($failedServices.Count -gt 0) {
            $failedServices | Out-File -FilePath "$folder\failed-services.txt"
            Write-Output "Escalation completed. Failed services are logged in '$folder\failed-services.txt'."
        }else{
            Write-Output "All services started successfully or already running."
        }

# -------- 11fol. Failed login ----------
$securityFile = "$folder\FailedSecurityEvents.txt"

try {
    Get-WinEvent -LogName Security | 
        Where-Object { $_.LevelDisplayName -eq "Failure Audit" } |
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Out-File -FilePath $securityFile 

    Write-Host " Failed security events saved to $securityFile"
}
catch {
    Write-Host " Failed to retrieve security events: $_"
}

# -------- Zip the folder -------------
$hostName = $env:COMPUTERNAME
$zipFile = "C:\AllReports_${hostName}_$(Get-Date -Format 'yyyyMMdd_HHmm').zip"

# -------- Compress the Zip File 

# Check if folder has any files before compressing
if (Test-Path $folder) {
    Write-Output "Checking if the file exists"
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
try{
    (Get-Date) | Out-File -FilePath "$folder\ScriptEndTime.txt" -Append
    Write-Output "Script End Time recorded successfully"
}catch{
    Write-Output "Failed to record Script End Time"
}
Write-Host "Script completed at $(Get-Date)"

# ---------- Clean Up --------------
Remove-Item -Path $folder -Recurse -Force
Write-Host "Temporary folder $folder has been removed."