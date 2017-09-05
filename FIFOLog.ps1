
function FIFOLog {
    <#   
   .SYNOPSIS   
       Creates a FIFO, (First in First Out) rolling log file.
        
   .DESCRIPTION   
       Creates and manages a single FIFO, (First In First Out) log file instead of using multiple log files. Oldest entries are
       removed 1st based on age.

    .PARAMETER LogDays (MANDATORY)
        Mandatory field to keep entries in log # number of days. (Used for log cleanup.)

    .PARAMETER FIFOLogPath (Optional)
        Optional path to log file. If omitted will use the current script folder and script name replacing .ps1 with .log file extension.

    .PARAMETER WriteLog (Optional)
        Optional value to write to log. If no value is given log cleanup is performance and no additional entries are made to the log.

    .NOTES   
        Author: Rick Bankers
        Version: 1.0      
    
    .EXAMPLE 
        FIFOLog -WriteLog "This is a test log entry." -LogDays 10
        (Writes to log file with the default log path and removes entries older than 10 days. )

        FIFOLog -WriteLog "This is a test log entry." -LogDays 10 -LogPath C:\Temp\MyFile.log
        (Writes to C:\Temp\MyFile.log file and removes entries older than 10 days. )

        FIFOLog -LogDays 3
        (Cleans up log entries older than 7 days. No new entries are written to log.)

   #>         
   [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()] 
        [int]$LogDays,

        [Parameter()]
        [string]$WriteLog,

        [Parameter()]
        [string]$LogPath = ($Script:MyInvocation.MyCommand.Path).Replace(".ps1", ".log")
    )

    Begin {   
        $NewFIFOLog = @()
        $FIFOContent = $null
        Filter TimeStamp {"$(Get-Date -Format s);$_"}
    }
    Process {
            If (Test-path -Path $LogPath) {
                $FIFOContent = get-content -Path $LogPath -ErrorAction SilentlyContinue
                $NewFIFOLog = $FIFOContent | Where-Object { ((Get-date) - [datetime]$_.Split(";")[0].trim()).Days -le $LogDays } | Out-String
            }
            $NewFIFOLog += $WriteLog | TimeStamp
    }
    End {
        Try {
            $NewFIFOLog | Set-content $LogPath
        }
        Catch {
            Write-Error "$($_.Exception.Message) - $($_.Exception.ItemName)"
        }
    }

}

<#
Examples:
====================================================================================
# Write to log.
FIFOLog -WriteLog "This is a test log entry #15." -LogDays 10

# Example to find a string in the log.
Get-content -Path $LogPath | Select-string -Pattern "This is a test log entry #15."
====================================================================================
#>