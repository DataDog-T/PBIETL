Import-Module PBIPREMIUM
#SELECT ACTIVITY PARAMAETERS
$tableName = "RefreshWaitTimes"
$datalakeFolder = "RefreshWait_Metrics"
$dailyDateofData = (get-date).AddDays(-1).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$Global:Logfilepath = ComputeNewValue $tableName
$logtime = (get-date).ToString("yyyMMdd_HH:mm:ss") | foreach {$_ -replace ":", "."}

Try {
Write-Log -Message 'AzCopy Initial Login Using Machine Identity' -Type "Script_CommandStart"
C:\Windows\azcopy\azcopy.exe login --identity
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "AzCopy Initial Login Using Machine Identity" -Type "CommandEnd"



#DON'T CHANGE:PIPELINE PARAMETERS
$Fullpath = $folderFullPath + $tableName + "_" + $dailyDateofData + ".csv"
$file_name= $tableName + "_" +  $dailyDateofData
$datalakeFinalPath = $datalakePath + $datalakeFolder + "/" + $tableName + "_" + $dailyDateofData + ".csv"

$query = ComputeNewDataCheckQuery RefreshWaitTimes
$latestrefresh = ComputeNewDataCheckQuery Timestamps
$sourcemetrics = PbiPremiumDataCheckInt "$query" $auth
$hours = PbiPremiumDataCheckInt "$latestrefresh" $auth

IF($hours.'[Hours]' -lt 24)
{ Write-Log -message ("Not all data is in source. Less than 24 hours," + $hours.'[Hours]' + " " + "hours exist in current source for yesterday's hourly data") -type "DataIntegrityError"
if(![System.IO.File]::Exists($Logfilepath))
{ }
else
{
Move-Item -Path $Logfilepath -Destination ("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\" + $tableName + "_" + $logtime + ".csv") }}

else
{
#QUERYFUNCTION
Try {
Write-Log -Message 'Initiating Export-PbiPremiumData Function from Module PBIPREMIUM' -Type "CommandStart"
Export-PbiPremiumData "EVALUATE CALCULATETABLE (Filter(RefreshWaitTimes, DATEDIFF(RefreshWaitTimes[timestamp],TODAY(),DAY)=1))" "$file_name" $folderFullPath $auth
}
catch
{Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message ("Initiating Export-PbiPremiumData Function from Module PBIPREMIUM" + $sourcemetrics.'[Hours]' + " " + "exist of use for yesterday") -Type "CommandEnd"

Try{
Write-Log -Message 'Copying CSV File to Datalake Folder Path and returning AZcopy JobID' -Type "CommandStart"
$firstjob = azCopyComputeRunningJobID $Fullpath $datalakeFinalPath return $firstjob.JOBID
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID)}
Write-Log -Message (ComputeNewValueazcopy $firstjob.JOBID) -Type "CommandEnd - AzCopy" -CopyDataJobId ($firstjob.JOBID)

$cleanuppath = $logDatalakePath + "Azcopy/" + $firstjob.JOBID + ".log"
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

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

if(![System.IO.File]::Exists($Logfilepath))
{ }
else
{
Move-Item -Path $Logfilepath -Destination ("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\" + $tableName + "_" + $logtime + ".csv") }
}