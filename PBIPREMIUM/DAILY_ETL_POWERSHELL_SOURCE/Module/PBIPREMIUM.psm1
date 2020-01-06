$global:folderFullPath = 'C:\Users\bvadmin\PBIPREMIUM\'
$env:ACCOUNT_NAME = "ngddatalake"
$env:AZCOPY_LOG_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS"
$env:AZCOPY_JOB_PLAN_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYPLANS"
$global:previousDay_yyyMMdd = (get-date).AddDays(-1).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$global:currentDay_yyyMMdd = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$global:Logfilepath = $null
$global:pbiAdminCredFile= "C:\Users\bvadmin\powerbicredssecure.txt"
$global:pbiAdminUserName = "mccunnt@bv.com"
$global:datalakePath = "https://ngddatalake.dfs.core.windows.net/staging/PBIPREMIUM/"
$global:logDatalakePath = "https://ngddatalake.dfs.core.windows.net/staging/Logs/PBIPREMIUM/"
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
   "C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUM_" + $tableName + "_" + $currentDay_yyyMMdd + ".csv"
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

function Export-PbiPremiumData{
    param(
        [string]$DAXQuery,
        [string]$OutputName,
        [string]$OutputFolder,
        [string]$Auth
    )

    Try { Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandStart"
    Connect-PowerBIServiceAccount -Credential $credential
    }
    catch
    { Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
    Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandEnd"

    $outFile = "$OutputFolder\$OutputName.csv"
    $auth = (Get-PowerBIAccessToken).Authorization
    $UserName = $credential.UserName
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
    $datasets = 
    Try { Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandStart"
     Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json 
     }
     catch
{
	Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName)
}
Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandEnd"

    $premiumAppDataset = $datasets |        
        foreach-Object { $_.value } |
        Where-Object { $_.name -eq "Power BI Premium Capacity Metrics"} |
        Select-Object -First 1

    if($premiumAppDataset){
    Try {
    Write-Log -Message 'Creating Premium Capacity Metrics App OLEDB MSOLAP Connection to Extract Information' -Type "CommandStart"
        $region = ([System.Uri]$datasets.'@odata.context').Host
        $datasetId = $premiumAppDataset.id
        $cs = "Provider=MSOLAP;Data Source=https://analysis.windows.net/powerbi/api;;Initial Catalog=$datasetId;Location=https://$region/xmla?vs=sobe_wowvirtualserver&db=$datasetId;MDX Compatibility= 1; MDX Missing Member Mode= Error; Safety Options= 2; Update Isolation Level= 2; Locale Identifier= 1033;User Id = $UserName; Password=$PlainPassword"
        $connection = New-Object System.Data.OleDb.OleDbConnection $cs
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand -ArgumentList $DAXQuery, $connection
        $rdr = $command.ExecuteReader()
        $result = New-Object System.Collections.ArrayList
        while($rdr.Read()){
            $properties = @{}
            for($fieldIndex = 0; $fieldIndex -lt $rdr.FieldCount; $fieldIndex ++){
                $properties[$rdr.GetName($fieldIndex)] = $rdr[$fieldIndex]
            }
            $row = New-Object PSObject -Property $properties
            $void = $result.Add($row)
        }
        $rdr.Close()
        $connection.Close()        
        $result | Export-Csv -Path $outFile -NoTypeInformation -Force
        }
        catch
        {
        Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName)
        }
       Write-Log -Message 'Creating Premium Capacity Metrics App OLEDB MSOLAP Connection to Extract Information' -Type "CommandEnd" 
    }
    else{
        Write-Log -Message "Premium Capacity Metrics app not found. Please install the app and try again."   -Type "Exception-AppNotFoundorInstalled"     
    }
    Try{
    Write-Log -Message "ResultQuerySetEmpty Check for Data Returned" -Type "CommandStart"
 $data = Get-childitem -File $outFile | select -property length 
 if ($data.length -lt 1)
 { Write-Log -Message "ResultQuerySetEmpty Check RawSource for Data Integrity" -Type "Exception-EmptyData"

}
else
{  Write-Log -Message "ResultQuerySet Not Empty and Passed Initial Data Integrity Check FileSize = $data" -Type "CommandEnd" }
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) 
}
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
