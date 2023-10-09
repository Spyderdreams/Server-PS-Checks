# Server-PS-Checks
Check Drive Space, Optimizes Drives, Checks Logs, and Last Updates

Purpose:
This PowerShell script gathers and outputs various details about a Windows system, performs some optimization tasks, and collects event log data for diagnostic purposes. The script aims to provide insights into the system's health and status, while also performing routine maintenance activities such as drive optimization.

Key Functions:
Collect System Information

Retrieves the hostname and current date.
Gathers physical drive details, including total and free space.
Drive Optimization

Automatically triggers optimization (ReTrim) for NTFS volumes.
Records the optimization status for each logical drive.
Event Log Analysis

Retrieves and groups error messages from the 'Application', 'System', and 'Security' event logs for the last 7 days.
Groups messages and counts their occurrences.
Update Installation Check

Checks the last time updates were installed and provides a timestamp.
Detailed Workflow:
Hostname and Date Retrieval

$hostname gets the name of the computer.
$date stores the current date in "yyyyMMdd" format.
Output Path Setting

$outputPath defines the path where the script’s output will be saved, embedding the hostname and date in the filename.
Physical Drive Detail Collection

Retrieves logical drive details, focusing on drives with DriveType equal to 3 (local disks).
Formats and stores details like total size, free space, and percentage of free space.
Drive Optimization

Iterates through all local disks and performs optimization using Optimize-Volume for NTFS file systems.
Stores the optimization status for each drive.
Event Log Analysis

Retrieves error messages from 'Application', 'System', and 'Security' logs, focusing on the last 7 days.
Groups messages by content and sorts them by occurrence count.
Update Installation Check

Queries the Win32_ReliabilityRecords for the latest entry related to Windows updates.
Extracts and formats the timestamp of the last update.
Output Generation

Combines all collected data and results into an array $results.
Outputs the results to a text file at the defined $outputPath.
Displays the output path in the console.
Output:
The script creates a text file that contains:
Details about the physical drives.
The optimization status of logical drives.
A summary of event logs from the past week.
The timestamp of the last installed update.
The output is saved to a defined path and the path is displayed in the console.
Usage:
Can be used by system administrators for routine checks and basic maintenance.
Helpful for gathering a quick overview of system status and recent event log entries.
May be scheduled to run at specific intervals for automated checks and maintenance.
Note:
Ensure that the script is run with sufficient permissions to access system details and perform optimization tasks.
Ensure that the output path exists or modify the script to create the path if it doesn't exist.
