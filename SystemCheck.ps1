# Get the hostname
$hostname = $env:COMPUTERNAME
$date = Get-Date -Format "yyyyMMdd"

# Set output path
$outputPath = "c:\temp\${hostname}_$date.txt"

# Collect physical drive details
$drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
$driveDetails = $drives | ForEach-Object {
    "${$_.DeviceID}:: $($_.Size/1GB -as [int])GB Total - $($_.FreeSpace/1GB -as [int])GB Free ($([math]::Round(($_.FreeSpace / $_.Size) * 100, 2))% Free)"
}

# Drive optimization status for HDDs and SSDs
$drivesOptimizationStatus = @()
foreach ($drive in $drives) {
    $partitions = Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$($drive.DeviceID)'} WHERE AssocClass=Win32_DiskDriveToDiskPartition"
    foreach ($partition in $partitions) {
        $logicalDisks = Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} WHERE AssocClass=Win32_LogicalDiskToPartition"
        foreach ($logicalDisk in $logicalDisks) {
            $driveLetter = $logicalDisk.DeviceID.Substring(0,1)
            $volume = Get-Volume -DriveLetter $driveLetter.Substring(0,1)
            if ($volume.FileSystemType -eq 'NTFS') {
                Optimize-Volume -DriveLetter $driveLetter -ReTrim -ErrorAction SilentlyContinue
                $status = "optimized"
            } else {
                $status = "optimization not applicable"
            }
            $drivesOptimizationStatus += "${driveLetter}: $status"
        }
    }
}

# Get unique error messages from the event logs from the last 7 days
$sevenDaysAgo = (Get-Date).AddDays(-7)
$applicationLogs = Get-WinEvent -LogName 'Application' -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt $sevenDaysAgo } | Group-Object -Property Message | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) - $($_.Count) occurrences" }
$systemLogs = Get-WinEvent -LogName 'System' -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt $sevenDaysAgo } | Group-Object -Property Message | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) - $($_.Count) occurrences" }
$securityLogs = Get-WinEvent -LogName 'Security' -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt $sevenDaysAgo } | Group-Object -Property Message | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) - $($_.Count) occurrences" }



# Check the last time updates were installed
$LastUpdate = Get-WmiObject -Query "SELECT * FROM Win32_ReliabilityRecords WHERE SourceName='Microsoft-Windows-WindowsUpdateClient'" | Sort-Object TimeGenerated -Descending | Select-Object -First 1
if ($LastUpdate) {
    $lastUpdateText = "Last Update Installed: $($LastUpdate.TimeGenerated)"
} else {
    $lastUpdateText = "No updates found in the reliability records."
}

# Combine all the results
$results = @(
    "Physical Drive Details:",
    "-----------------------",
    $driveDetails,
    "",
    "Drive Optimization Status:",
    "--------------------------",
    $drivesOptimizationStatus,
    "",
    "Event Logs from the last 7 days:",
    "--------------------------------",
    $eventLogs,
    "",
    $lastUpdateText
)

$results | Out-File $outputPath -Encoding utf8

Write-Output "Output saved to $outputPath"

