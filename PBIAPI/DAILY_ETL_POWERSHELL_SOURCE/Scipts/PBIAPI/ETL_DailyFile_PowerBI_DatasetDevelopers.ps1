﻿Import-Module PBIAPI
#SELECT ACTIVITY PARAMAETERS
$tableName = "Dataset_Developers"
$datalakeFolder = "Dataset_Developers"
$dailyDateofData = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$Global:Logfilepath = ComputeNewValue $tableName

Try {
Write-Log -Message 'AzCopy Initial Login Using Machine Identity' -Type "Script_CommandStart"
C:\Windows\azcopy\azcopy.exe login --identity
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "AzCopy Initial Login Using Machine Identity" -Type "CommandEnd"

#DON'T CHANGE:PIPELINE PARAMETERS
$Fullpath = $PBIfolderFullPath + $tableName + "_" + $dailyDateofData + ".csv"
$file_name= $tableName + "_" +  $dailyDateofData
$datalakeFinalPath = $PBIdatalakePath + $datalakeFolder + "/" + $tableName + "_" + $dailyDateofData + ".csv"


Try {
Write-Log -Message 'Connecting to PBI Service Account using Admin credentials' -Type "Script_CommandStart"
Connect-PowerBIServiceAccount -Credential $credential #call to connect and auth PBI
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "Connecting to PBI Service Account using Admin credentials" -Type "CommandEnd"




Try {
Write-Log -Message 'Using PBIRESTAPI calling (https://api.powerbi.com/v1.0/myorg/admin/datasets Get)' -Type "Script_CommandStart"
$datasets =Invoke-PowerBIRestMethod -Url "https://api.powerbi.com/v1.0/myorg/admin/datasets" -Method Get| ConvertFrom-Json 
$datasets | foreach-Object { $_.value } | Select-Object | Export-Csv -path $Fullpath
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message 'Using PBIRESTAPI calling (https://api.powerbi.com/v1.0/myorg/admin/datasets Get)' -Type "CommandEnd"

Try{
Write-Log -Message 'Copying CSV File to Datalake Folder Path and returning AZcopy JobID' -Type "CommandStart"
$firstjob = azCopyComputeRunningJobID $Fullpath $datalakeFinalPath return $firstjob.JOBID
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID)}
Write-Log -Message (ComputeNewValueazcopy $firstjob.JOBID) -Type "CommandEnd - AzCopy" -CopyDataJobId ($firstjob.JOBID)

$cleanuppath = $PBIlogDatalakePath + "Azcopy/" + $firstjob.JOBID + ".log"
$logpath = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $firstjob.JOBID + ".log"

Try { Write-Log -Message "Copying Default AZCOPY LogFile to Datalake Folder" -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID)
$logjob = azCopyComputeRunningJobID $logpath $cleanuppath return $logjob.JOBID
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}
Write-Log -Message (ComputeNewValueazcopy $logjob.JOBID) -Type "CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up File that Successfully Copied to Datalake' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)
Remove-Item $Fullpath
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID) }

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up data copy log fil created for Azopy' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $firstjob.JOBID + ".log")
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up copylogfile job log created for Azopy' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $logjob.JOBID + ".log")
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}


if(![System.IO.File]::Exists($Logfilepath))
{ }
else
{
Move-Item -Path $Logfilepath -Destination ("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\" + $tableName + "_" + $currentDay_yyyMMdd + ".csv") }

