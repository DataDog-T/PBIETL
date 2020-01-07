$global:PBIfolderFullPath = 'C:\Users\test\PBIAPI\'
$env:ACCOUNT_NAME = "test"
$env:AZCOPY_LOG_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS"
$env:AZCOPY_JOB_PLAN_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYPLANS"
$global:currentDay_yyyMMdd = (get-date).ToString("yyyMMdd_HH:mm:ss") | foreach {$_ -replace ":", "."}
$global:Logfilepath = $null
$global:jobsid = $null
$global:pbiAdminCredFile= "C:\Users\test\powerbicredssecure.txt"
$global:pbiAdminUserName = "test@test.com"
$global:PBIdatalakePath = "https://test.dfs.core.windows.net/staging/PBIAPI/"
$global:PBIlogDatalakePath = "https://test.dfs.core.windows.net/staging/Logs/PBIAPI/"
$global:AZCOPYMessageContent = $null
$global:AZCOPYMessageType = (C:\Windows\azcopy\azcopy.exe jobs list --output-type json | ConvertFrom-Json | Select-Object MessageType -OutVariable string -First 1)
$global:credential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $pbiAdminUserName, (Get-Content $pbiAdminCredFile | ConvertTo-SecureString) 

 
 function azCopyComputeRunningJobID ($fileToCopy,$datalakeFullPath)
{ 
C:\Windows\azcopy\azcopy.exe copy $fileToCopy $datalakeFullPath --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5 --output-type=json | ConvertFrom-Json | Select-Object MessageType,MessageContent | Where-Object MessageType -EQ "INIT" | 
Select-Object @{l='LogFileLocation';e={$_.MessageContent.Split(',')[1]}} | Select-Object @{l='JobID';e={$_.LogFileLocation.Split(":")[1]}} | Select-Object @{l='JOBID';e={$_.JobID.Replace("""","")}} -OutVariable string 
}

function ComputeNewValue ($tableName)
{
   "C:\Program Files\WindowsPowerShell\Logs\PBIAPI_" + $tableName + "_" + $currentDay_yyyMMdd + ".csv"
}

function ComputeNewValueazcopy ($jobsid)
{
   C:\Windows\azcopy\azcopy.exe jobs show "$jobsid"  --output-type json  | ConvertFrom-Json | Select-Object MessageContent -OutVariable string -First 1
}

function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$ScriptName,
        [int]$ScriptLineNumber,

        [Parameter()]
        [string]$Type,
        [string]$CopyDataJobId,
        [string]$CopyLogJobId
    )
    
    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'ScriptName' = $MyInvocation.ScriptName
        'ScriptLineNumber' = $MyInvocation.ScriptLineNumber
        'Message' = $Message
        'Type' = $Type
        'CopyDataJobId' = $CopyDataJobId
        'CopyLogJobId' = $CopyLogJobId
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    $line | Export-Csv -Path $Logfilepath -Append -NoTypeInformation
}

function Get-ResultSize { 
param(
        [string]$FolderPath
    )

Try{
 Get-childitem -File   | select -property fullname, length | Export-csv -notypeinformation -path "C:\Program Files\WindowsPowerShell\Logs\ExportDataSizes.csv" -Append
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) 
}
}

function Get-CurrentLineNumber {
    $MyInvocation.ScriptLineNumber
}


function Get-CurrentFileName {
    $MyInvocation.ScriptName
}


